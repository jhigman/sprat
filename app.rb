require "rubygems"
require 'sinatra'
require 'sinatra/config_file'
require "yaml"
require 'haml'
require "google_drive"
require "csv"
require "json"
require "jsonpath"
require 'rest_client'
require 'redis'
require 'resque'

config_file 'config/config.yml'

class SpratTestRunner < Sinatra::Application

  enable :sessions

  set :session_secret, 'my sooper secret'

  set :username, ENV["GOOGLE_DRIVE_USERNAME"] unless settings.respond_to? :username
  set :password, ENV["GOOGLE_DRIVE_PASSWORD"] unless settings.respond_to? :password

  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  else
    redis = Redis.new
  end
  set :redis, redis

  Resque.redis = redis

end

require_relative 'models/init'
require_relative 'routes/init'
