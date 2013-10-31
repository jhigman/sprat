module Sprat
  class API

    def initialize(host, uri, apikey = nil)
      @host = host
      @uri = uri
      @apikey = apikey
    end

    def make_call(params = {})

      if @uri.empty?
        raise RuntimeError.new("No API specified")
      end

      return "";

      unless @apikey.nil?
        params = {:apikey => @apikey}.merge(params)
      end

      api_url = 'https://' + @host + @uri
      response = RestClient.get @uri, {:params => params, :content_type => :json, :accept => :json}
      return response.to_str

    end

  end
end