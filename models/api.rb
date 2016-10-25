module Sprat
  class API

    def initialize(host)
      @host = host
    end

    def get(uri, params = {})
      endpoint = make_endpoint(@host, uri)
      response = RestClient.get endpoint, {:params => params, :content_type => :json, :accept => :json}
      response.to_str.force_encoding('UTF-8')
    end

    def make_uri(uri, params = {})
      endpoint = make_endpoint(@host, uri)
      uri_endpoint = URI(endpoint)
      uri_endpoint.query = URI.encode_www_form(params)
      uri_endpoint.to_s
    end

    private

    def make_endpoint(host, uri)

      raise RuntimeError.new("No host specified") if host.empty?

      uri = '/' if uri.empty?

      if host =~ /^http/
        host + uri
      else
        'https://' + host + uri
      end

    end


  end
end