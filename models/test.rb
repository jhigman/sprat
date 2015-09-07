module Sprat
  class Test

    attr_accessor :id

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

    def make_expected_date(str, format="%d/%m/%Y")
      Date.strptime(str,format) rescue nil
    end

    def make_actual_date(str)
      Date.parse(str) rescue nil
    end

    def make_comparable(val)
      if val.is_a? Array
        val = val.join(",")
      end
      return val.to_s.gsub(/\s+/, "")
    end

    def is_equal(expected, actual)
      expected_date = make_expected_date(expected)
      actual_date = make_actual_date(actual)
      if expected_date && actual_date
        return make_comparable(expected_date) ==  make_comparable(actual_date)
      else
        return make_comparable(expected) == make_comparable(actual)
      end
    end

    def make_jsonpath(str)
      if(str[0] != '$')
        str = '$.["' + str + '"]'
      end
      str
    end

    def get_response_value(response, jsonpath)
      JsonPath.new(jsonpath).first(response)
    end

    def failed_expectation_message(key, expected, actual)
      expected = "nothing" if expected.to_s == ""
      actual = "nothing" if actual.to_s == ""
      "Expected #{expected.to_s} for '#{key.to_s}', but found #{actual.to_s}"
    end

    def check_expectations_jsonpath(response, msgs)
      @outputs.each do |output|
        key = make_jsonpath(output['path'])
        expected = output['value']
        actual = get_response_value(response, key)
        if !is_equal(expected, actual)
          msgs << failed_expectation_message(output['label'], expected, actual)
        end
      end
    end

    def check_expectations_array(response, msgs)
      if response.empty? && @outputs.any?{|output| !output['value'].empty?}
        msgs << "No results returned"
        return
      end
      @outputs.each do |output|
        key = output['path']
        expected = output['value']
        if is_true(expected)
          if !response.include? key
            msgs << "#{key} not found"
          end
        else
          if response.include? key
            msgs << "#{key} should not have been found"
          end
        end
        response.delete(key)
      end
      if response.size > 0
        msgs << "#{response.join(",")} should not have been found"
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

    def make_result(msgs, params, json, api)

      ret = Hash.new
      ret['id'] = @id
      ret['params'] = params
      ret['request'] = api.make_uri(params)
      ret['response'] = json
      if msgs.length == 0
        ret['result'] = 'PASS'
        ret['reason'] = ''
      else
        ret['result'] = 'FAIL'
        ret['reason'] = "#{msgs.join('.')}"
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
        msgs << "#{e.response[0,100]}"
      rescue => e
        msgs << "#{e.message}"
      end

      return make_result(msgs, params, json, api)

    end

  end
end