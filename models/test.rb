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

  def check_expectations_array(responses, msgs)
    @outputs.each do |key, expected|
      if is_true(expected)
        if !responses.include? key
          msgs << "#{key} not found"
        end
      else
        if responses.include? key
          msgs << "#{key} should not have been found"
        end
      end
    end
  end

  def check_expectations_hash(responses, msgs)
    @outputs.each do |key, expected|
      if expected
        actual = responses[key]
        if actual.to_s != expected.to_s
          msgs << "Expected #{expected.to_s} for #{key.to_s}, but found #{actual.to_s}"
        end
      end
    end
  end

  def check_expectations(responses, msgs)
    puts "response type is : " + responses.class.name
    case responses.class.name
      when 'Array'
        check_expectations_array(responses, msgs)
      when 'Hash'
        check_expectations_hash(responses, msgs)
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
      check_expectations(response, msgs)
    rescue RestClient::Exception => e
      msgs << "#{e.message}"
      msgs << "#{e.response.to_s}"
    rescue => e
      msgs << "#{e.message}"
    end

    return make_result(msgs)

  end

end
