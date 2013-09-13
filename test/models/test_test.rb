require 'test/unit'
require 'rspec/mocks'

require_relative '../../app.rb'

class TestTest < Test::Unit::TestCase

  def test_make_result
    test = Sprat::Test.new(1,[],[])

    result = test.make_result([], {}, '')
    assert_equal 'PASS', result['result'] 

    result = test.make_result(['message one', 'message two'], {}, '')
    assert_equal 'FAIL', result['result'] 
  end

  def test_get_response_type
    test = Sprat::Test.new(1,[],[])

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

  def test_get_response_values_simple_array
    test = Sprat::Test.new(1,[],[])

    # simple array
    response = [ 'one', 'two' ]

    jsonpath = '$.[0]'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    jsonpath = '$.[1]'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

  end

  def test_get_response_values_simple_hash
    test = Sprat::Test.new(1,[],[])

    # simple hash
    response = { 'first' => 'one', 'second' => 'two' }

    jsonpath = '$.first'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

    jsonpath = '$.second'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

  end

  def test_get_response_values_with_root
    test = Sprat::Test.new(1,[],[])

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

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

  end

  def test_get_response_values_without_root
    test = Sprat::Test.new(1,[],[])

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

    response = [item1, item2]

    jsonpath = '$.[0].name'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['one'], result

  end

  def test_get_response_values_from_simple_hash
    test = Sprat::Test.new(1,[],[])

    response = {'name first' => 'one', 'name second' => 'two'}

    jsonpath = '$.["name second"]'
    result = test.get_response_values(response, jsonpath)
    assert_equal ['two'], result

  end


  # originally a bug in JSONPath
  def test_get_empty_response_values_when_path_not_found
    test = Sprat::Test.new(1,[],[])

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

    response = [item1, item2]

    jsonpath = '$.[99].name'
    result = test.get_response_values(response, jsonpath)
    assert_equal [], result
  end

  def test_check_expectations_jsonpath

    outputs = [
      { 'path' => '$.root[0].name', 'value' => 'one', 'label' => 'Name1'},
      { 'path' => '$.root[1].name', 'value' => 'two', 'label' => 'Name2'}
    ]

    test = Sprat::Test.new(1,[],outputs)

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}

    # root element has name
    response = { 'root' => [item1, item2]}

    msgs = []
    test.check_expectations_jsonpath(response, msgs)

    assert_equal [], msgs
    
  end

  def test_exec_handles_empty_response

    # set up rspec mock support  
    RSpec::Mocks::setup(self)    

    test = Sprat::Test.new(1,{},[])
    api = double("Sprat::API")
    api.stub(:make_call) { '' }

    results = test.exec(api)

    assert_equal 'FAIL', results['result'] 
    assert_equal 'Response from api was empty', results['reason'] 
  end

end