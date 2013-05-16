class ApiTest

  def initialize(source, apikey)
    @source = source
    @apikey = apikey
  end

  def do_test(row, results)

    test_id = row[0]
    country = row[3]
    region = row[4]
    bite_avoidance = row[5].to_s.upcase
    puts "Processing test ID: #{test_id}"

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
      result = expected
      reason = Time.now
    rescue Exception => e
      result = !expected
      reason = e.message
    end

    if result == expected
      results << { :id => test_id, :result => "PASS", :reason => reason }
    else
      reason = "bite_avoidance didn't match!" unless reason
      results << { :id => test_id, :result => "FAIL", :reason => reason }
    end

  end

  def test_malaria_prevalence
  
      tests = @source.get_tests

      puts "Running tests..."

      results = []
      tests.each { |test| do_test(test, results) }

      # @source.reset_spreadsheet()
      # @source.update_spreadsheet(@results)
      
      return results

  end
end
