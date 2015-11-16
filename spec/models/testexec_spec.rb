require_relative '../../app.rb'

#  NB file can't be called 'test_spec.rb' because rspec doesn't redognise it by default

describe Sprat::Test do

  it "should handle empty responses in exec" do

    test = Sprat::Test.new(1,{},[])

    api = double(:api)
    expect(api).to receive(:make_call) {''}
    expect(api).to receive(:make_uri)

    results = test.exec(api)

    expect(results.result).to eql('FAIL')
    expect(results.reason).to eql('Response from api was empty')

  end

end