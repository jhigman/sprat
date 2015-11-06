module Sprat
  class ExpectationsMatcherJson

    def initialize(response)
      @response = response
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
      val.to_s.gsub(/\s+/, "")
    end

    def is_equal(expected, actual)
      expected_date = make_expected_date(expected)
      actual_date = make_actual_date(actual)
      if expected_date && actual_date
        make_comparable(expected_date) ==  make_comparable(actual_date)
      else
        make_comparable(expected) == make_comparable(actual)
      end
    end

    def make_jsonpath(str)
      if(str[0] != '$')
        str = '$.["' + str + '"]'
      end
      str
    end

    def get_response_value(jsonpath)
      JsonPath.new(jsonpath).first(@response)
    end

    def failed_expectation_message(key, expected, actual)
      expected = "nothing" if expected.to_s == ""
      actual = "nothing" if actual.to_s == ""
      "Expected #{expected.to_s} for '#{key.to_s}', but found #{actual.to_s}"
    end

    def match(outputs)
      msgs = []
      outputs.each do |output|
        key = make_jsonpath(output['path'])
        expected = output['value']
        actual = get_response_value(key)
        if !is_equal(expected, actual)
          msgs << failed_expectation_message(output['label'], expected, actual)
        end
      end
      msgs
    end


  end
end