require_relative '../../app.rb'

describe Sprat::API do

  it "should raise exception in make endpoint" do
    api = Sprat::API.new
    expect{api.make_endpoint(nil, "/index.php")}.to raise_error(RuntimeError)
  end

  it "should make endpoint" do
    api = Sprat::API.new
    expect(api.make_endpoint("example.com", nil)).to eql('https://example.com/')
    expect(api.make_endpoint("example.com", "/index.php")).to eql('https://example.com/index.php')
    expect(api.make_endpoint("http://example.com", nil)).to eql('http://example.com/')
    expect(api.make_endpoint("http://example.com", "/index.php")).to eql('http://example.com/index.php')
  end

end