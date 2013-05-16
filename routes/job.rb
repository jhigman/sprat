get '/jobs' do
  @name = session[:spreadsheet]
  haml :jobs
end

post '/jobs' do

  puts "Running tests for spreadsheet : " + request["name"]

  doc = request["name"]
  session[:spreadsheet] = doc

  job = Job.new(doc, settings)

  results = job.exec 

  id = Time.now.to_i

  File.open("/tmp/#{id}.json", 'w') { |file| file.write(results.to_json) }

  puts "Done!"

  redirect "/results/#{id}" 

end