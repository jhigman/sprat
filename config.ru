require './app.rb'
require 'resque/server'

run Rack::URLMap.new \
  "/"       => SpratTestRunner.new,
  "/resque" => Resque::Server.new
