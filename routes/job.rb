get '/jobs/new' do
  @spreadsheet = session[:spreadsheet]
  @worksheet = session[:worksheet]
  haml :job
end

get '/jobs' do
  @spreadsheet = session[:spreadsheet]
  @worksheet = session[:worksheet]
  @jobs = Array.new
  job_ids = settings.redis.lrange("jobs", 0, 20) 
  job_ids.each {|n| @jobs << Sprat::Job.load(n)}
  haml :jobs
end

get '/jobs/:id' do
  id = params[:id]
  @job = Sprat::Job.load(id)
  haml :job
end

post '/jobs' do

  spreadsheet = request["spreadsheet"]
  worksheet = request["worksheet"]
  local = request["local"] ? 1 : 0

  session[:spreadsheet] = spreadsheet
  session[:worksheet] = worksheet
  session[:local] = local

  job = Sprat::Job.new
  job.spreadsheet = spreadsheet
  job.worksheet = worksheet
  job.local = local
  job.created = Time.now
  job.save

  if request["submit"] == "Run Now"
    job.exec
    redirect "/jobs/#{job.id}"
  else
    if Resque.enqueue(Sprat::Job, job.id)
      redirect "/jobs"
    else
      error "Sorry, something went hideously wrong, and we failed to queue the job"
    end
  end

end
