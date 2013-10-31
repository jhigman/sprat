require 'test/unit'
require 'rspec/mocks'

require_relative '../../app.rb'

class ApiTest < Test::Unit::TestCase

  def test_make_call_throws_exception

    api = Sprat::API.new("example.com", "")

    begin    
      api.make_call 
      assert(false, "Didn't get expected exception")
    rescue => e
      assert_equal 'No API specified', e.message
    end

  end


end