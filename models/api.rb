class API

  def initialize(uri, apikey)
    @uri = uri
    @apikey = apikey
  end

  def make_call(params)
    unless @apikey.nil?
      params = {:apikey => @apikey}.merge(params)
    end
    response = RestClient.get @uri, {:params => params, :content_type => :json, :accept => :json}
    return response.to_str
  end


end
