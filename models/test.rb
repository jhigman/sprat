module GoogleDriveTestRunner
  class Test

    def initialize(id, inputs, outputs)
      @id = id
      @inputs = inputs
      @outputs = outputs
    end

    def get_params
      return @inputs
    end

    # def compare_boolean(left, right)
    #   return !!left == !!right
    # end

    def is_true(val)
      return ['y', 'yes', 'true', 't', '1'].include? val.to_s.downcase 
    end

    def get_response_values(response, jsonpath)
      path = JsonPath.new(jsonpath)
      path.on(response)
    end

    def check_expectations_jsonpath(response, msgs)
      @outputs.each do |key, expected|
        # ignore entries with no expectation
        if expected.to_s != ""
          # making assumption that result we want is the first one matched..?
          actual = get_response_values(response, key).first
          if actual.to_s != expected.to_s
            msgs << "Expected #{expected.to_s} for #{key.to_s}, but found #{actual.to_s}"
          end
        end
      end
    end

    def check_expectations_array(response, msgs)
      # want to ignore case, so downcase everything
      downcased = response.map(&:downcase)
      @outputs.each do |key, expected|
        if is_true(expected)
          if !downcased.include? key
            msgs << "#{key} not found"
          end
        else
          if downcased.include? key
            msgs << "#{key} should not have been found"
          end
        end
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
      rescue
        msgs << "hm, something went wrong while checking the expectations.."
      end
    end

    def make_result(msgs)
      ret = Hash.new
      ret['id'] = @id
      if msgs.length == 0
        ret['result'] = 'PASS'
        ret['reason'] = ''
      else
        ret['result'] = 'FAIL'
        ret['reason'] = "#{msgs.join(',')}"
      end
      return ret
    end

    def exec(api)

      msgs = []

      begin
        params = get_params
        json = api.make_call(params)
        response = JSON.parse(json)
        if response.empty?
          msgs << "Response from api was empty"
        else
          check_expectations(response, msgs)
        end
      rescue RestClient::Exception => e
        msgs << "#{e.message}"
        msgs << "#{e.response.to_s}"
      rescue => e
        msgs << "#{e.message}"
      end

      return make_result(msgs)

    end

  end
end