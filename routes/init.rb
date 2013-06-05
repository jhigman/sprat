require_relative 'job'
require_relative 'result'

get '/' do
  haml :index
end

