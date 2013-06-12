get '/jobs' do
  @spreadsheet = session[:spreadsheet]
  @worksheet = session[:worksheet]
  @jobs = Array.new
  job_ids = settings.redis.lrange("jobs", -100, 100) 
  job_ids.each {|n| @jobs << Job.load(n)}
  haml :jobs
end

get '/jobs/:id' do
  id = params[:id]
  @job = Job.load(id)
  haml :job
end

post '/jobs' do

  puts "Running tests for spreadsheet : " + request["spreadsheet"] + " (" + request["worksheet"] + ")"

  spreadsheet = request["spreadsheet"]
  worksheet = request["worksheet"]

  session[:spreadsheet] = spreadsheet
  session[:worksheet] = worksheet

  job = Job.new
  job.spreadsheet = spreadsheet
  job.worksheet = worksheet
  job.save

  if Resque.enqueue(Job, job.id)
    redirect "/jobs/#{job.id}"
  else
    error "Sorry, something went hideously wrong, and we failed to queue the job"
  end

end
