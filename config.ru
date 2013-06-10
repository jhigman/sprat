require './app.rb'
require 'resque/server'

# We should probably run under a redis namespace.
# For now we can get by with a named queue.
#Resque.redis.namespace = "resque:GDocTestRunner"

run Rack::URLMap.new \
  "/"       => GDocTestRunner.new,
  "/resque" => Resque::Server.new
