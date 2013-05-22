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

    source.reset_spreadsheet()

    results = tester.run(source)

    source.update_spreadsheet(results)

    File.open("/tmp/#{@id}.json", 'w') { |file| file.write(results.to_json) }

  end

end
