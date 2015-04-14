require 'minitest/autorun'
require 'rack/test'

require_relative '../../app.rb'

class AppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_root_path
    get '/'
    assert_includes last_response.body, 'SPRAT : Spreadsheet API Test Runner'
  end

end