module Sprat
  class Test

    def initialize(id, inputs, outputs)
      @id = id
      @inputs = inputs
      @outputs = outputs
    end

    def get_params
      return @inputs
    end

    def is_true(val)
      return ['y', 'yes', 'true', 't', '1'].include? val.to_s.downcase 
    end

    def is_equal(val1, val2)
      val1.to_s == val2.to_s
    end

    def get_response_value(response, jsonpath)
      JsonPath.new(jsonpath).first(response)
    end

    def get_response_values(response, jsonpath)
      JsonPath.new(jsonpath).on(response)
    end

    def failed_expectation_message(key, expected, actual)
      expected = "nothing" if expected.to_s == ""
      actual = "nothing" if actual.to_s == ""
      "Expected #{expected.to_s} for '#{key.to_s}', but found #{actual.to_s}"
    end
    
    def check_expectations_jsonpath(response, msgs)
      @outputs.each do |output|
        key = output['path']
        expected = output['value']
        actual = get_response_value(response, key)
        if !is_equal(expected, actual)
          msgs << failed_expectation_message(output['label'], expected, actual)
        end
      end
    end

    def check_expectations_array(response, msgs)
      # want to ignore case, so downcase everything
      downcased = response.map(&:downcase)
      @outputs.each do |output|
        key = output['path']
        expected = output['value']
        if is_true(expected)
          if !downcased.include? key
            msgs << "#{key} not found"
          end
        else
          if downcased.include? key
            msgs << "#{key} should not have been found"
          end
        end
        downcased.delete(key)
      end
      if downcased.size > 0
        msgs << "#{downcased.join(",")} should not have been found"
      end
    end

    def get_response_type(response)
      case response.class.name
        when 'Array'
          response.each do |r|
            if !['String', 'Fixnum', 'Float'].include? r.class.name
              return 'Hash'
            end
          end
          return 'Array'
        when 'Hash'
          return 'Hash'
        end
    end

    def check_expectations(response, msgs)
      begin
        case get_response_type(response)
          when 'Array'
            check_expectations_array(response, msgs)
          else
            check_expectations_jsonpath(response, msgs)
        end
      rescue => e
        msgs << "hm, something went wrong while checking the expectations "
        msgs << "(#{e.message})"
      end
    end

    def make_result(msgs, params, json)
      ret = Hash.new
      ret['id'] = @id
      if msgs.length == 0
        ret['result'] = 'PASS'
        ret['reason'] = ''
        ret['params'] = params
        ret['response'] = json
      else
        ret['result'] = 'FAIL'
        ret['reason'] = "#{msgs.join('.')}"
        ret['params'] = params
        ret['response'] = json
      end
      return ret
    end

    def exec(api)

      msgs = []

      begin
        params = get_params
        json = api.make_call(params)
        if json.empty?
          msgs << "Response from api was empty"
        else
          response = JSON.parse(json)
          check_expectations(response, msgs)
        end
      rescue RestClient::Exception => e
        msgs << "#{e.message}"
        msgs << "#{e.response.to_s}"
      rescue => e
        msgs << "#{e.message}"
      end

      return make_result(msgs, params, json)

    end

  end
end