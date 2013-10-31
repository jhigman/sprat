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

      if @host.empty?
        raise RuntimeError.new("No host specified")
      end

      unless @apikey.nil?
        params = {:apikey => @apikey}.merge(params)
      end

      if @host =~ /localhost/ 
        protocol = 'http'
      else
        protocol = 'https'
      end

      endpoint = protocol + '://' + @host + @uri
      response = RestClient.get endpoint, {:params => params, :content_type => :json, :accept => :json}
      return response.to_str

    end

  end
end