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

    store = double(:store)
    expect(store).to receive(:load_jobs) {[]}

    app.set :store, store

    get '/jobs'

    expect(last_response.status).to eql(200)
    expect(last_response.body).to include("Jobs")

  end

end