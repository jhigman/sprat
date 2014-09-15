require 'test/unit'
require 'rspec/mocks'

require_relative '../../app.rb'

class ApiTest < Test::Unit::TestCase

  def test_make_endpoint_throws_exception

    api = Sprat::API.new

    begin
      api.make_endpoint(nil, "/index.php")
      assert(false, "Didn't get expected exception")
    rescue => e
      assert_equal 'No host specified', e.message
    end

  end

  def test_make_endpoint

    api = Sprat::API.new
    assert_equal 'https://example.com/', api.make_endpoint("example.com")

    api = Sprat::API.new
    assert_equal 'https://example.com/index.php', api.make_endpoint("example.com", "/index.php")

    api = Sprat::API.new
    assert_equal 'http://example.com/', api.make_endpoint("http://example.com")

    api = Sprat::API.new
    assert_equal 'http://example.com/index.php', api.make_endpoint("http://example.com", "/index.php")

  end


end