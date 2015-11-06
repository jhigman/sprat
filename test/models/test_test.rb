require 'minitest/autorun'

require_relative '../../app.rb'

class TestTest < Minitest::Test

  def test_exec_handles_empty_response

    test = Sprat::Test.new(1,{},[])

    api = MiniTest::Mock.new
    api.expect(:make_call, '', [{}])
    api.expect(:make_uri, '', [{}])

    results = test.exec(api)

    api.verify
    assert_equal 'FAIL', results.result
    assert_equal 'Response from api was empty', results.reason

  end

end