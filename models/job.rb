class Job
  @queue = :test_jobs
  attr_accessor :id

  def initialize(spreadsheet, worksheet, job_id = Time.now.to_i, app_settings = GDocTestRunner.settings)
    @spreadsheet = spreadsheet
    @worksheet = worksheet
    @settings = app_settings
    @id = job_id
  end

  def exec()

    source = GDriveTestSource.new(@spreadsheet, @worksheet, @settings.username, @settings.password)
    source.update_status("Running")    
    source.reset_spreadsheet()

    tester = Tester.new
    results = tester.run(source)

    source.update_spreadsheet(results)

    tr = TestResult.new(@id, results.to_json, @settings)
    tr.save

    source.update_status("Finished at " + Time.now.to_s)

  end

  def self.perform(spreadsheet, worksheet)
    job = Job.new(spreadsheet, worksheet)
    job.exec
  end

end
