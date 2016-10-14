get '/jobs/new' do
  @spreadsheet = request[:spreadsheet] ? request[:spreadsheet] : session[:spreadsheet]
  @worksheet = request[:worksheet] ? request[:worksheet] : session[:worksheet]
  @host = request[:host] ? request[:host] : session[:host]
  haml :job
end

get '/jobs' do
  @jobs = Sprat::Job.all(:order => [:id.desc])
  haml :jobs
end

get '/jobs/summary' do
  @jobs = Sprat::Job.all(:order => [:id.desc])
  if request["host"]
    @host = request["host"]
    @jobs.select!{|job| job.host == @host}
  end
  if request["spreadsheet"]
    @spreadsheet = request["spreadsheet"]
    @jobs.select!{|job| job.spreadsheet == request["spreadsheet"]}
  end
  summary_jobs = []
  @jobs.each do |job|
    if !summary_jobs.any?{|selected_job| selected_job.worksheet == job.worksheet}
      summary_jobs << job
    end
  end
  @jobs = summary_jobs.sort_by(&:worksheet)
  haml :summary
end

post '/jobs/summary' do

  params = []
  if !request["host"].empty?
    @host = request["host"]
    params << "host=#{@host}"
  end
  if !request["spreadsheet"].empty?
    @spreadsheet = request["spreadsheet"]
    params << "spreadsheet=#{@spreadsheet}"
  end

  if request[:job_ids]
    request[:job_ids].keys.each do |job_id|
      job = Sprat::Job.get!(job_id)
      if job
        new_job = Sprat::Job.new
        new_job.spreadsheet = job.spreadsheet
        new_job.worksheet = job.worksheet
        new_job.host = job.host
        new_job.local = job.local
        new_job.status = "Scheduled"
        new_job.created_at = Time.now
        new_job.save!
        Resque.enqueue(Sprat::Job, new_job.id)
      end
    end
  end

  redirect "/jobs/summary?" + params.join('&')
end

get '/jobs/:id' do
  id = params[:id]
  @job = Sprat::Job.get!(id)
  @results = @job.results
  haml :job
end

post '/jobs' do

  spreadsheet = request["spreadsheet"]
  worksheet = request["worksheet"]
  host = request["host"]
  local = request["local"] ? 1 : 0

  session[:spreadsheet] = spreadsheet
  session[:worksheet] = worksheet
  session[:host] = host
  session[:local] = local

  worksheets = []

  if worksheet.empty?
    book = Sprat::Book.new(spreadsheet, settings)
    book.sheets.each do |sheet|
      worksheets << sheet.title unless sheet.title == 'Summary'
    end
  else
    worksheets << worksheet
  end

  worksheets.each do |name|
    job = Sprat::Job.new
    job.spreadsheet = spreadsheet
    job.worksheet = name
    job.host = host
    job.local = local
    job.status = "Scheduled"
    job.created_at = Time.now
    job.save!

    Resque.enqueue(Sprat::Job, job.id)
  end

  redirect "/jobs"

end
