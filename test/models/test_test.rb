require 'test/unit'

require_relative '../../app.rb'

class TestTest < Test::Unit::TestCase

  def test_make_result
    test = GoogleDriveTestRunner::Test.new(1,[],[])

    result = test.make_result([])
    assert_equal 'PASS', result['result'] 

    result = test.make_result(['message one', 'message two'])
    assert_equal 'FAIL', result['result'] 
  end

end