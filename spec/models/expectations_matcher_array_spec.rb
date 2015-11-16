require_relative '../../app.rb'

describe Sprat::ExpectationsMatcherArray do

  it "should identify extra items in response" do

    outputs = [
      { 'path' => 'one', 'value' => '', 'label' => 'one'},
      { 'path' => 'two', 'value' => 'Y', 'label' => 'two'},
      { 'path' => 'three', 'value' => '', 'label' => 'three'}
    ]

    response = [ 'two', 'four', 'five' ]

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    expect(matcher.match(outputs)).to eql(["four,five should not have been found"])

  end

  it "should be case sensitive" do

    outputs = [
      { 'path' => 'One', 'value' => 'Y', 'label' => 'one'}
    ]

    response = [ 'ONE' ]

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    expect(matcher.match(outputs)).to eql(["One not found", "ONE should not have been found"])

  end

  it "test_identifies_empty_array" do

    outputs = [
      { 'path' => 'one', 'value' => 'Y', 'label' => 'one'}
    ]

    response = []

    matcher = Sprat::ExpectationsMatcherArray.new(response)

    expect(matcher.match(outputs)).to eql(["No results returned"])

  end

end