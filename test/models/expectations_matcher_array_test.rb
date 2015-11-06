require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class ExpectationsMatcherArrayTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  def test_identifies_extras

    outputs = [
      { 'path' => 'one', 'value' => '', 'label' => 'one'},
      { 'path' => 'two', 'value' => 'Y', 'label' => 'two'},
      { 'path' => 'three', 'value' => '', 'label' => 'three'}
    ]

    response = [ 'two', 'four', 'five' ]

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    msgs = matcher.match(outputs)

    assert_equal ["four,five should not have been found"], msgs

  end

  def test_is_case_sensitive

    outputs = [
      { 'path' => 'One', 'value' => 'Y', 'label' => 'one'}
    ]

    response = [ 'ONE' ]

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    msgs = matcher.match(outputs)

    assert_equal ["One not found", "ONE should not have been found"], msgs

  end

  def test_identifies_empty_array

    outputs = [
      { 'path' => 'one', 'value' => 'Y', 'label' => 'one'}
    ]

    response = []

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    msgs = matcher.match(outputs)

    assert_equal ["No results returned"], msgs

  end

end