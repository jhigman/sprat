require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class TestFactoryTest < Minitest::Test

  def test_get_tests

    rows = []
    rows << []
    rows << ['Tests', 'Result', 'Reason', 'country', 'region', 'disease' ]
    rows << ['', '', '', 'france', 'any', 'hep a' ]
    rows << ['', '', '', 'germany', 'rhein', 'cholera' ]

    config = {'parameters' => ['country', 'region']}

    factory = Sprat::TestFactory.new(rows, config)

    tests = factory.tests

    assert_equal 2, tests.size

    test = tests.first

    assert_equal 1, test.id
    assert_equal 2, test.inputs.size
    assert_equal 'france', test.inputs['country']
    assert_equal 'any', test.inputs['region']
    assert_equal 1, test.outputs.size
    assert_equal 'hep a', test.outputs.first['value']
    assert_equal 'disease', test.outputs.first['label']
    assert_equal 'disease', test.outputs.first['path']

    test = tests.last
    assert_equal 2, test.id
    assert_equal 2, test.inputs.size
    assert_equal 'germany', test.inputs['country']
    assert_equal 'rhein', test.inputs['region']
    assert_equal 1, test.outputs.size
    assert_equal 'cholera', test.outputs.first['value']
    assert_equal 'disease', test.outputs.first['label']
    assert_equal 'disease', test.outputs.first['path']

  end


end