require_relative 'job'

get '/' do
  redirect "/jobs"
end

post '/reset' do
  Sprat::Result.destroy
  Sprat::Job.destroy
  redirect "/jobs"
end
