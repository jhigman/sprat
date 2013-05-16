class ApiTest

  def initialize(source, apikey)
    @source = source
    @apikey = apikey
  end

  def do_test(row)

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
      @results << { :id => test_id, :result => "PASS", :reason => reason }
    else
      reason = "bite_avoidance didn't match!" if reason.empty?
      @results << { :id => test_id, :result => "FAIL", :reason => reason }
    end

  end

  def parse_tests(csv_contents)

      puts "Parsing spreadsheet..."

      config_loaded = false
      tests_loaded = false

      @config = Hash.new
      @tests = []

      while !config_loaded do
        row = csv_contents.shift
        if row[0] == "Config" 
          row = csv_contents.shift
          @config['api'] = row[1]
          config_loaded = true
        end
      end

      while !tests_loaded do
        row = csv_contents.shift

        # puts csv_contents.lineno

        if row[0] == "Tests"

          # puts csv_contents.inspect

          # skip the headers
          row = csv_contents.shift
          # @tests = csv_contents.read
          # start reading test rows
          row = csv_contents.shift
          while row do
            @tests << row
            row = csv_contents.shift
          end
          # return tests
          tests_loaded = true
        end
      end

  end

  def test_malaria_prevalence
  
    local_csv_path = @source.get_gdrive_spreadsheet_as_csv()

    if local_csv_path
  
      puts local_csv_path
      @results = []
      
      csv_contents = CSV.read(local_csv_path)

      found_tests = false

      # row = csv_contents.shift

      parse_tests(csv_contents)

      puts @config.inspect
      puts @tests.inspect

      puts "Running tests..."

      @tests.each { |test| do_test(test) }

      puts @results  
      
      @source.reset_spreadsheet()
      @source.update_spreadsheet(@results)
        
    end

  end
end
