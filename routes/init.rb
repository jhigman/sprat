require_relative 'job'

get '/' do
  redirect "/jobs"
end

post '/reset' do
  Sprat::Result.destroy
  Sprat::Job.destroy
  redirect "/jobs"
end

post '/truncate' do
  offset = request["keep"].to_i || 120
  jobs = Sprat::Job.all(offset: offset, limit: 50, order: [:id.desc])
  jobs.destroy
  redirect "/jobs"
end
