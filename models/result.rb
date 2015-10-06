module Sprat
  class Result

    attr_accessor :id, :job_id, :params, :request, :response, :result, :reason

    def initialize(id, params, request, response, messages)
      @id = id
      @params = params
      @request = request
      @response = response
      @reason = messages.join('.')
      @result = messages.empty? ? 'PASS' : 'FAIL'
    end

  end
end