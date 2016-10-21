module Sprat
  class Test

    attr_accessor :params, :expectations

    def initialize(params, expectations)
      @params = params
      @expectations = expectations
    end


    def exec(api)

      msgs = []

      begin

        json = api.make_call(@params)

        if json.empty?
          msgs << "Response from api was empty"
        else
          response = JSON.parse(json)

          matcher = ExpectationsMatcher.create(response)
          msgs = matcher.match(@expectations)

        end

      rescue RestClient::Exception => e
        msgs << "#{e.message}"
        msgs << "#{e.response[0,100]}"
      rescue => e
        msgs << "#{e.message}"
      end

      Sprat::Result.new(params: @params, request: api.make_uri(@params), response: json, result: (msgs.empty? ? 'PASS' : 'FAIL'), reason: msgs.join('.'))

    end

    def ==(other)
      other.params == @params && other.expectations == @expectations
    end
  end
end
