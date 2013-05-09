class TestDataSource
  require "rubygems"
  require "google_drive"
  require "csv"
  require "yaml"

  config = YAML.load_file('config.yml')
  puts config.inspect

  @username = config['username']
  @password = config['password']

  def self.get_gdrive_spreadsheet_as_csv(name, sheet = 1)
    csv_path = "/tmp/#{name}.csv"
    session = GoogleDrive.login(@username, @password)
    raise "GDrive session failed" unless session

    doc = session.spreadsheet_by_title(name)
    doc.export_as_file csv_path, "csv", sheet
    return csv_path
  end

  def self.update_spreadsheet(name, sheet, test_results)
    session = GoogleDrive.login(@username, @password)
    raise "GDrive session failed" unless session

    ws = session.spreadsheet_by_title(name).worksheets[sheet]
puts test_results.inspect
    test_results.each do |result|
      ws[result[:id].to_i+1, 2] = result[:result]
      ws[result[:id].to_i+1, 3] = result[:reason]
      ws.save
    end
  end
end

class ApiTest
  def self.test_malaria_prevalence
    print "Getting spreadsheet..."
    local_csv_path = TestDataSource.get_gdrive_spreadsheet_as_csv("test.malaria_prevalence", 3)
    puts "done."

    if local_csv_path
      puts local_csv_path
      test_results = []
      first_row = true
      CSV.foreach(local_csv_path) do |row|
        if first_row
          first_row = false
          next
        end

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
          result = API.call("bite_avoidance?country= &region=")
          reason = ""
        rescue Exception => e
          result = !expected
          reason = e.message
        end

        if result == expected
          test_results << { :id => test_id, :result => "PASS", :reason => reason }
        else
          reason = "bite_avoidance didn't match!" if reason.empty?
          test_results << { :id => test_id, :result => "FAIL", :reason => reason }
        end
      end

      TestDataSource.update_spreadsheet("test.malaria_prevalence", 3, test_results)
    else
      raise "BORKEN"
    end
  end
end

ApiTest.test_malaria_prevalence

