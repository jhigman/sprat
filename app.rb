require 'sinatra'
require "yaml"
require 'haml'
require "rubygems"
require "google_drive"
require "csv"
require "json"
require 'rest_client'

class GDocTestRunner < Sinatra::Application

  enable :sessions
  set :session_secret, 'my sooper secret'

  config = YAML.load_file('config.yml')

  set :username, config['username']
  set :password, config['password']
  set :apikey, config['apikey']
  set :results, []

end

require_relative 'models/init'
require_relative 'routes/init'

