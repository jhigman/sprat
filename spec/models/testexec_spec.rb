require_relative '../../app.rb'

#  NB file can't be called 'test_spec.rb' because rspec doesn't recognise it by default

describe Sprat::Test do

  it "should handle empty responses in exec" do

    api = double(:api)
    expect(api).to receive(:get).and_return('')

    test = Sprat::Test.new('/api/stuff', {},[])


    results = test.exec(api)

    expect(results.result).to eql('FAIL')
    expect(results.reason).to eql('Response from api was empty')

  end

end