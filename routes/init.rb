require_relative 'job'

get '/' do
  redirect "/jobs"
end

post '/reset' do
  SpratTestRunner.settings.store.clear
  redirect "/jobs"
end
