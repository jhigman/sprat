class Tester

  def initialize(app_settings = GDocTestRunner.settings)
    @settings = app_settings
  end

  def make_call(uri, params)
    unless @settings.apikey.nil?
      params = {:apikey => @settings.apikey}.merge(params)
    end

    response = RestClient.get uri, {:params => params, :content_type => :json, :accept => :json}
    return response.to_str
  end

  # def compare_boolean(left, right)
  #   return !!left == !!right
  # end

  # def do_test(row, meta, results)

  #   puts "Processing test : " + row.inspect
  #   puts "Meta : " + meta.inspect

  #   api = meta['api']

  #   test_id = row[0]
  #   country = row[3]
  #   region = row[4]
  #   bite_avoidance = row[5].to_s.upcase

  #   if bite_avoidance == 'Y'
  #     expected = true
  #   elsif bite_avoidance == 'N'
  #     expected = false
  #   else
  #     raise "WTF? #{bite_avoidance}"
  #   end

  #   begin
  #     # result = PrescriptionEngine.bite_avoidance?(country, region)
  #     # result = API.call("/api/bite_avoidance?country= &region=&apikey=12345")
  #     # result = API.call("/country/region?apikey=12345")
  #     # reason = "{ disease_prevalence: true,  }"
  #     result = make_call api, {:country => country, :region => region}
  #     reason = Time.now
  #   rescue Exception => e
  #     result = !expected
  #     reason = e.message
  #   end

  #   if compare_boolean(result,expected)
  #     results << { :id => test_id, :result => "PASS", :reason => reason }
  #   else
  #     reason = "bite_avoidance didn't match!" unless reason
  #     results << { :id => test_id, :result => "FAIL", :reason => reason }
  #   end

  # end

  # def test_malaria_prevalence
  
  #     tests = @source.get_tests
  #     meta = @source.get_meta

  #     puts "Running tests..."

  #     results = []
  #     tests.each { |test| do_test(test, meta, results) }

  #     # @source.reset_spreadsheet()
  #     # @source.update_spreadsheet(@results)
      
  #     return results

  # end

  def is_true(val)
    return ['y', 'yes', 'true', 't', '1'].include? val.to_s.downcase 
  end

  def do_test(id, test, source)

    ret = Hash.new

    test.shift # id
    test.shift # result
    test.shift # reason

    country = test.shift

    headers = source.get_test_headers

    api = source.get_config('api')

    json = make_call api, {:country => country}
    diseases = JSON.parse(json)

    # puts "result from api : " + diseases.inspect

    i = 0
    msgs = []
    while i <= test.length
      current = headers[i]
      val = test[i]
      if is_true(val)
        if !diseases.include? current
          msgs << "#{current} not found"
        end
      else
        if diseases.include? current
          msgs <<  "#{current} should not have been found"
        end
      end
      i += 1
    end

    ret['id'] = id
    if msgs.length == 0
      ret['result'] = 'PASS'
      ret['reason'] = ''
    else
      ret['result'] = 'FAIL'
      ret['reason'] = "#{country} : #{msgs.join(',')}"
    end

    return ret
  end

  def run(source)

    puts "Running tests"
    
    results = []
    
    index = 1
    while (test = source.get_test_row(index))
      results << do_test(index, test, source)
      index += 1
    end

    return results

  end

end
