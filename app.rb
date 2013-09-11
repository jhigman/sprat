require "rubygems"
require 'sinatra'
require "yaml"
require 'haml'
require "google_drive"
require "csv"
require "json"
require "jsonpath"
require 'rest_client'
require 'redis'
require 'resque'

class GDocTestRunner < Sinatra::Application

  enable :sessions
  set :session_secret, 'my sooper secret'

  set :username, ENV["GOOGLE_DRIVE_USERNAME"]
  set :password, ENV["GOOGLE_DRIVE_PASSWORD"]

  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    set :redis, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    set :redis, Redis.new
  end
  
end

require_relative 'models/init'
require_relative 'routes/init'

