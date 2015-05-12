require_relative 'job'

get '/' do
  redirect "/jobs"
end

post '/reset' do
  SpratTestRunner.settings.redis.flushall
  redirect "/jobs"
end
