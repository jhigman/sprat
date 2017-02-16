require 'rubygems'
require 'data_mapper'
require 'dm-core'
require 'dm-redis-adapter'
require 'sinatra'
require 'sinatra/config_file'
require 'yaml'
require 'haml'
require 'google/api_client'
require 'google_drive'
require 'csv'
require 'json'
require 'jsonpath'
require 'rest_client'
require 'redis'
require 'resque'

configure(:development) do
  require 'rspec'
  require 'byebug'
end

require_relative 'models/init'
require_relative 'routes/init'

config_file 'config/config.yml'


class SpratApp < Sinatra::Application

  enable :sessions

  set :session_secret, 'my sooper secret'

  if ENV["GOOGLE_CLIENT_EMAIL"]
    google_client_email = ENV["GOOGLE_CLIENT_EMAIL"]
  end

  if ENV["GOOGLE_P12_FILE"]
    google_p12_file = ENV["GOOGLE_P12_FILE"]
  end

  if ENV["GOOGLE_P12_SECRET"]
    google_p12_secret = ENV["GOOGLE_P12_SECRET"]
  end

  if ENV["REDISCLOUD_URL"]
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    redis_host = uri.host
    redis_port = uri.port
    redis_password = uri.password
  end

  DataMapper.setup :default, { adapter: 'redis', host: redis_host, port: redis_port, password: redis_password}
  Resque.redis = Redis.new(host: redis_host, port: redis_port, password: redis_password)

  DataMapper.finalize

  DataMapper::Model.raise_on_save_failure = true

  DataMapper.auto_migrate!

end
