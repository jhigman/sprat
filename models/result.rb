module Sprat
  class Result

    attr_accessor :id, :params, :request, :response, :result, :reason

    def initialize(id, params, request, response, result, reason)
      @id = id
      @params = params
      @request = request
      @response = response
      @result = result
      @reason = reason
    end

    def to_json
      JSON.dump ({id: id, params: params, request: request, response: response, result: result, reason: reason})
    end

    def self.from_json(json)
      data = JSON.load(json)
      self.new(data['id'], data['params'], data['request'], data['response'], data['result'], data['reason'])
    end

  end
end