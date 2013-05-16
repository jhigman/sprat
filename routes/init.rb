
get '/' do
  @name = session[:spreadsheet]
  haml :index
end

get '/result' do
  haml :result
end

post '/job' do

  puts "Running tests for speadsheet : " + request["name"]

  session[:spreadsheet] = request["name"]

  config = YAML.load_file('config.yml')
  puts config.inspect

  username = config['username']
  password = config['password']
  apikey = config['apikey']
  # doc = config['doc']
  doc = request["name"]

  source = TestDataSource.new(doc, username, password)
  tester = ApiTest.new(source, apikey)

  tester.test_malaria_prevalence()

  puts "Done!"

  redirect "/result"

end