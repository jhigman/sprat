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

  def test_get_response_type
    test = GoogleDriveTestRunner::Test.new(1,[],[])

    response = ['one', 'two']
    result = test.get_response_type(response)
    assert_equal 'Array', result 

    response = [1, 2, 3.5]
    result = test.get_response_type(response)
    assert_equal 'Array', result 

    response = {'one' => 'a string', 'two' => 'another string'}
    result = test.get_response_type(response)
    assert_equal 'Hash', result 

    response = {'one' => ['string 1', 'string 2']}
    result = test.get_response_type(response)
    assert_equal 'Hash', result 

  end

  def test_get_response_values
    test = GoogleDriveTestRunner::Test.new(1,[],[])

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

    # root element has name
    response = { 'root' => [item1, item2]}

    jsonpath = '$.root[0].name'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    jsonpath = '$.root[1].name'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

    jsonpath = '$..name'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one','two'], result

    # root element not named
    response = [item1, item2]

    jsonpath = '$.[0].name'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    # simple hash
    response = { 'first' => 'one', 'second' => 'two' }

    jsonpath = '$.first'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    jsonpath = '$.second'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

    # simple array
    response = [ 'one', 'two' ]

    jsonpath = '$.[0]'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    jsonpath = '$.[1]'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

  end

  def test_check_expectations_jsonpath

    outputs = { '$.root[0].name' => 'one', '$.root[1].name' => 'two', }

    test = GoogleDriveTestRunner::Test.new(1,[],outputs)

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

    # root element has name
    response = { 'root' => [item1, item2]}

    msgs = []
    test.check_expectations_jsonpath(response, msgs)

    assert_equal msgs, []
    
  end

end