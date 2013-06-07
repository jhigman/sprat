get '/jobs' do
  @spreadsheet = session[:spreadsheet]
  @worksheet = session[:worksheet]
  haml :jobs
end

post '/jobs' do

  puts "Running tests for spreadsheet : " + request["spreadsheet"] + " (" + request["worksheet"] + ")"

  spreadsheet = request["spreadsheet"]
  worksheet = request["worksheet"]
  session[:spreadsheet] = spreadsheet
  session[:worksheet] = worksheet

  job_id = Time.now.to_i
  if Resque.enqueue(Job, spreadsheet, worksheet)
    session[:flash] = {:success => "Job #{job_id} queued successfully." }
  else
    session[:flash] = {:error => "Failed to queue job #{job_id}." }
  end

  redirect "/results"

end
