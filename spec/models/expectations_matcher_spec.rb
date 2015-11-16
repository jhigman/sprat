require_relative '../../app.rb'

describe Sprat::ExpectationsMatcher do

  it "should create an array matcher" do

    response = []
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherArray)

    response = ['one', 'two']
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherArray)

    response = [1, 2, 3.5]
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherArray)

  end

  it "should create a json matcher" do

    response = {}
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherJson)

    response = {'one' => 'a string', 'two' => 'another string'}
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherJson)

    response = {'one' => ['string 1', 'string 2']}
    matcher = Sprat::ExpectationsMatcher.create(response)
    expect(matcher.class).to eql(Sprat::ExpectationsMatcherJson)

  end

end