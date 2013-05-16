require 'sinatra'
require "yaml"
require 'haml'
require "rubygems"
require "google_drive"
require "csv"

class GDocTestRunner < Sinatra::Application
  enable :sessions
  set :session_secret, 'my sooper secret'
end

require_relative 'models/init'
require_relative 'routes/init'
