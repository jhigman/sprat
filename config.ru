require './app.rb'
require 'resque/server'

run Rack::URLMap.new \
  "/"       => SpratApp.new,
  "/resque" => Resque::Server.new
