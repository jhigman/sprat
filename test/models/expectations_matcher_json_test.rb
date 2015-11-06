require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class ExpectationsMatcherJsonTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  def test_matches_integer_and_string

    outputs = [
      { 'path' => '$.[0].item', 'value' => '23', 'label' => 'Item1'}
    ]

    item1 = {'item' => 23}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_integer_strings

    outputs = [
      { 'path' => '$.[0].item', 'value' => '23', 'label' => 'Item1'}
    ]

    item1 = {'item' => '23'}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_decimal_numbers

    outputs = [
      { 'path' => '$.[0].item', 'value' => 6.78, 'label' => 'Item1'}
    ]

    item1 = {'item' => 6.78}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end


  def test_matches_string_and_decimal

    outputs = [
      { 'path' => '$.[0].item', 'value' => '6.78', 'label' => 'Item1'}
    ]

    item1 = {'item' => 6.78}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end


  def test_matches_strings

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello', 'label' => 'Item1'},
      { 'path' => '$.[1].item', 'value' => 'one, two, three', 'label' => 'Item2'}
    ]

    item1 = {'item' => 'hello'}
    item2 = {'item' => 'one, two, three'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_strings_ignoring_whitespace

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello, matey', 'label' => 'Item1'},
    ]

    item1 = {'item' => "    hello  \r\n    ,  matey "}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_arrays

    outputs = [
      { 'path' => '$.[0].item', 'value' => 'hello', 'label' => 'Item1'},
      { 'path' => '$.[1].item', 'value' => 'one,    two,   three', 'label' => 'Item2'},
      { 'path' => '$.[2].item', 'value' => 'one,two,three', 'label' => 'Item3'},
    ]

    item1 = {'item' => ["hello"]}
    item2 = {'item' => ["one", "two", "three"]}
    item3 = {'item' => ["one", "   two", "three"]}
    response = [item1, item2, item3]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_expected_dates_in_correct_formats

    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-24", 'label' => 'Item1'}
    ]

    item1 = {'item' => "2014-01-24"}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs


    outputs = [
      { 'path' => '$.[0].item', 'value' => "24/01/2014", 'label' => 'Item1'}
    ]

    msgs = matcher.match(outputs)

    assert_equal [], msgs


    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-23", 'label' => 'Item1'}
    ]

    msgs = matcher.match(outputs)

    assert_equal ["Expected 2014-01-23 for 'Item1', but found 2014-01-24"], msgs

    outputs = [
      { 'path' => '$.[0].item', 'value' => "24 Jan 2014", 'label' => 'Item1'}
    ]

    msgs = matcher.match(outputs)

    assert_equal ["Expected 24 Jan 2014 for 'Item1', but found 2014-01-24"], msgs


    outputs = [
      { 'path' => '$.[0].item', 'value' => "2014-01-24T12:34", 'label' => 'Item1'}
    ]

    msgs = matcher.match(outputs)

    assert_equal ["Expected 2014-01-24T12:34 for 'Item1', but found 2014-01-24"], msgs


  end


  def test_matches_dates_ignoring_times

    outputs = [
      { 'path' => '$.[0].item', 'value' => "24/01/2014", 'label' => 'Item1'}
    ]

    item1 = {'item' => "2014-01-24T13:45"}
    response = [item1]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_comma_in_jsonpath_fails

    outputs = [
      { 'path' => "$.['one, two']", 'value' => "some value", 'label' => 'Item1'}
    ]

    response = {["one, two"] => "some value"}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    # really we want to get "some value" returned, but comma is reserved for ranges in jsonpath
    assert_equal ["Expected some value for 'Item1', but found nothing"], msgs


  end


  def test_matches_simple_array

    outputs = [
      { 'path' => "$.[0]", 'value' => "one", 'label' => 'Item1'},
      { 'path' => "$.[1]", 'value' => "two", 'label' => 'Item2'}
    ]

    response = ["one", "two"]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_simple_hash

    outputs = [
      { 'path' => "$.first", 'value' => "one", 'label' => 'Item1'},
      { 'path' => "$.second", 'value' => "two", 'label' => 'Item2'}
    ]

    response = { 'first' => 'one', 'second' => 'two' }

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_paths_with_root

    outputs = [
      { 'path' => '$.root[0].name', 'value' => "one", 'label' => 'Item1'},
      { 'path' => '$.root[1].name', 'value' => "two", 'label' => 'Item2'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = { 'root' => [item1, item2]}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs


  end

  def test_matches_paths_without_root

    outputs = [
      { 'path' => '$.[0].name', 'value' => 'one', 'label' => 'Name1'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_matches_paths_with_spaces

    outputs = [
      { 'path' => '$.["name second"]', 'value' => 'two', 'label' => 'Name1'}
    ]

    response = {'name first' => 'one', 'name second' => 'two'}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal [], msgs

  end

  def test_handles_path_not_found_despite_jsonpath_bug

    outputs = [
      { 'path' => '$.[99].name', 'value' => 'one', 'label' => 'Name1'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = [item1, item2]

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal ["Expected one for 'Name1', but found nothing"], msgs
  end

  def test_nested_hash_value_is_case_sensitive

    outputs = [
      { 'path' => '$.root[0].name', 'value' => 'one', 'label' => 'Name1'},
      { 'path' => '$.root[1].name', 'value' => 'TWO', 'label' => 'Name2'}
    ]

    item1 = {'name' => 'one'}
    item2 = {'name' => 'two'}
    response = { 'root' => [item1, item2]}

    matcher = Sprat::ExpectationsMatcherJson.new(response)

    msgs = matcher.match(outputs)

    assert_equal ["Expected TWO for 'Name2', but found two"], msgs

  end


end