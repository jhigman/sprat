get '/jobs/new' do
  @spreadsheet = request[:spreadsheet] ? request[:spreadsheet] : session[:spreadsheet]
  @worksheet = request[:worksheet] ? request[:worksheet] : session[:worksheet]
  @host = request[:host] ? request[:host] : session[:host]
  haml :job
end

get '/jobs' do
  @jobs = Array.new
  job_ids = settings.redis.lrange("jobs", 0, 100)
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
  job.created = Time.now
  job.save

  if request["queue"]
    if Resque.enqueue(Sprat::Job, job.id)
      redirect "/jobs"
    else
      error "Sorry, something went hideously wrong, and we failed to queue the job"
    end
  else
    job.exec
    redirect "/jobs/#{job.id}"
  end

end
