class Job

  attr_accessor :id

  def initialize(spreadsheet, worksheet, settings)
    @spreadsheet = spreadsheet
    @worksheet = worksheet
    @settings = settings
    @id = Time.now.to_i
  end

  def exec()
    
    source = GDriveTestSource.new(@spreadsheet, @worksheet, @settings.username, @settings.password)
    
    tester = Tester.new

    source.update_status("Running")    

    source.reset_spreadsheet()

    results = tester.run(source)

    source.update_spreadsheet(results)

    File.open("/tmp/#{@id}.json", 'w') { |file| file.write(results.to_json) }

    source.update_status("Finished at " + Time.now.to_s)
    
  end

end
