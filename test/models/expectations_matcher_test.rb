require 'minitest/autorun'

require_relative '../../app.rb'

class ExpectationsMatcherTest < Minitest::Test

  def test_create_array_matcher

    response = []
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherArray, matcher.class

    response = ['one', 'two']
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherArray, matcher.class

    response = [1, 2, 3.5]
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherArray, matcher.class

  end

  def test_create_json_matcher

    response = {}
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherJson, matcher.class

    response = {'one' => 'a string', 'two' => 'another string'}
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherJson, matcher.class

    response = {'one' => ['string 1', 'string 2']}
    matcher = Sprat::ExpectationsMatcher.create(response)
    assert_equal Sprat::ExpectationsMatcherJson, matcher.class

  end

end