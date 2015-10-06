require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class ResultTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  def test_result_status

    result = Sprat::Result.new(@id, [], '/api/get_stuff', '', [])
    assert_equal 'PASS', result.result

    result = Sprat::Result.new(@id, [], '/api/get_stuff', '', ['some error'])
    assert_equal 'FAIL', result.result

  end

end