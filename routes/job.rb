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

  job = Job.new(spreadsheet, worksheet, settings)

  job.exec 

  redirect "/results/#{job.id}" 

end