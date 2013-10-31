require 'test/unit'
require 'rack/test'

require_relative '../../app.rb'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_path
    get '/'
    assert_includes last_response.body, 'SPRAT : Spreadsheet API Test Runner' 
  end

end