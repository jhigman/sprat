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

  config = YAML.load_file(File.join('config', 'config.yml'))

  set :username, config['username']
  set :password, config['password']

  uri = URI.parse(ENV["REDISCLOUD_URL"])
  set :redis, Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)

end

require_relative 'models/init'
require_relative 'routes/init'

