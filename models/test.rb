module Sprat
  class Test

    attr_accessor :id, :inputs, :outputs

    def initialize(id, inputs, outputs)
      @id = id
      @inputs = inputs
      @outputs = outputs
    end


    def exec(api)

      msgs = []

      begin

        params = @inputs

        json = api.make_call(params)

        if json.empty?
          msgs << "Response from api was empty"
        else
          response = JSON.parse(json)

          matcher = ExpectationsMatcher.create(response)
          msgs = matcher.match(@outputs)

        end

      rescue RestClient::Exception => e
        msgs << "#{e.message}"
        msgs << "#{e.response[0,100]}"
      rescue => e
        msgs << "#{e.message}"
      end

      Sprat::Result.new(@id, params, api.make_uri(params), json, (msgs.empty? ? 'PASS' : 'FAIL'), msgs.join('.'))

    end

  end
end
