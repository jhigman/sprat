require_relative '../../app.rb'

describe Sprat::API do

  it "should raise exception in make endpoint" do
    api = Sprat::API.new('')
    expect{api.get('/index.php')}.to raise_error(RuntimeError)
  end

  it "adds https protocol if none specified on host" do
    api = Sprat::API.new('example.com')
    expect(api.make_uri('')).to eql('https://example.com/?')
    expect(api.make_uri('/index.php')).to eql('https://example.com/index.php?')
  end

  it "handles hostname with protocol" do
    api = Sprat::API.new('http://example.com')
    expect(api.make_uri('')).to eql('http://example.com/?')
    expect(api.make_uri('/index.php')).to eql('http://example.com/index.php?')
  end

  it "handles params" do
    api = Sprat::API.new('example.com')
    expect(api.make_uri('', {foo: 'blah'})).to eql('https://example.com/?foo=blah')
  end

end