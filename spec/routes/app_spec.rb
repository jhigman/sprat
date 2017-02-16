require 'rack/test'

require_relative '../../app.rb'

describe 'Sinatra App' do

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "should redirect root to jobs page" do
    get '/'
    expect(last_response.status).to eql(302)
    expect(last_response.location).to eql("http://example.org/jobs")
  end

  it "should display jobs page" do
    get '/jobs'
    expect(last_response.status).to eql(200)
    expect(last_response.body).to include("Jobs")
  end

  it "should truncate jobs" do
    Sprat::Job.destroy
    5.times { Sprat::Job.new.save }
    expect(Sprat::Job.all.size).to eql(5)
    post '/truncate?keep=2'
    expect(Sprat::Job.all.size).to eql(2)
  end

end