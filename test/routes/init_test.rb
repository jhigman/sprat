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
    assert_equal last_response.status, 302
    assert_equal last_response.location, "http://example.org/jobs"
  end

end