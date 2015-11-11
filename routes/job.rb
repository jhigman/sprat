get '/jobs/new' do
  @spreadsheet = request[:spreadsheet] ? request[:spreadsheet] : session[:spreadsheet]
  @worksheet = request[:worksheet] ? request[:worksheet] : session[:worksheet]
  @host = request[:host] ? request[:host] : session[:host]
  haml :job
end

get '/jobs' do
  @jobs = settings.store.load_jobs
  if request["host"]
    @jobs.select!{|job| job.host == request["host"]}
  end
  if request["spreadsheet"]
    @jobs.select!{|job| job.spreadsheet == request["spreadsheet"]}
  end
  if request["summary"]
    summary_jobs = []
    @jobs.each do |job|
      if !summary_jobs.any?{|selected_job| selected_job.worksheet == job.worksheet}
        summary_jobs << job
      end
    end
    @jobs = summary_jobs
  end
  haml :jobs
end

get '/jobs/:id' do
  id = params[:id]
  @job = settings.store.load_job(id)
  @results = settings.store.load_results(@job)
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

  job = Sprat::Job.new
  job.spreadsheet = spreadsheet
  job.worksheet = worksheet
  job.host = host
  job.local = local
  job.created_at = Time.now

  job = settings.store.save_job(job)

  if request["queue"]
    Resque.enqueue(Sprat::Job, job.id)
  else
    job.exec
  end

  redirect "/jobs/#{job.id}"

end
