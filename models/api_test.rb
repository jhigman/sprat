class ApiTest

  def initialize(source, apikey)
    @source = source
    @apikey = apikey
  end

  def make_call(uri, params)
  
    response = RestClient.get uri, {:params => params}

    puts "response was : " + response.inspect

    return response.to_str

  end

  def compare_boolean(left, right)
    return !!left == !!right
  end

  def do_test(row, meta, results)

    puts "Processing test : " + row.inspect
    puts "Meta : " + meta.inspect

    api = meta['api']

    test_id = row[0]
    country = row[3]
    region = row[4]
    bite_avoidance = row[5].to_s.upcase

    if bite_avoidance == 'Y'
      expected = true
    elsif bite_avoidance == 'N'
      expected = false
    else
      raise "WTF? #{bite_avoidance}"
    end

    begin
      # result = PrescriptionEngine.bite_avoidance?(country, region)
      # result = API.call("/api/bite_avoidance?country= &region=&apikey=12345")
      # result = API.call("/country/region?apikey=12345")
      # reason = "{ disease_prevalence: true,  }"
      result = make_call api, {:country => country, :region => region}
      reason = Time.now
    rescue Exception => e
      result = !expected
      reason = e.message
    end

    if compare_boolean(result,expected)
      results << { :id => test_id, :result => "PASS", :reason => reason }
    else
      reason = "bite_avoidance didn't match!" unless reason
      results << { :id => test_id, :result => "FAIL", :reason => reason }
    end

  end

  def test_malaria_prevalence
  
      tests = @source.get_tests
      meta = @source.get_meta

      puts "Running tests..."

      results = []
      tests.each { |test| do_test(test, meta, results) }

      # @source.reset_spreadsheet()
      # @source.update_spreadsheet(@results)
      
      return results

  end
end
