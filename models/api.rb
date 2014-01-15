module Sprat
  class API

    def initialize(host = nil, uri = nil, apikey = nil)
      @host = host
      @uri = uri
      @apikey = apikey
    end

    def make_endpoint(host = nil, uri = nil)

      if host.nil?
        raise RuntimeError.new("No host specified")
      end

      if uri.nil?
        uri = "/"
      end

      if host =~ /^http/
        endpoint = host + uri
      else
        if host =~ /localhost/ 
          protocol = 'http'
        else
          protocol = 'https'
        end
        endpoint = protocol + '://' + host + uri
      end 
      endpoint
    end

    def make_call(params = {})

      unless @apikey.nil?
        params = {:apikey => @apikey}.merge(params)
      end

      endpoint = make_endpoint(@host, @uri)

      response = RestClient.get endpoint, {:params => params, :content_type => :json, :accept => :json}
      return response.to_str.force_encoding('UTF-8')

    end

  end
end