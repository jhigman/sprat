class Job

  @queue = :test_jobs
  
  attr_accessor :id, :spreadsheet, :worksheet, :settings, :status, :results

  def initialize(app_settings = GDocTestRunner.settings)
    @settings = app_settings
    @status = "Pending"
  end

  def self.load(id)
    job = new
    job.id = id
    Job.var_names.each {|name| job.instance_variable_set("@#{name}", job.settings.redis.hget("jobs:#{job.id}", name))}
    job
  end

  def get_id
    if @id == nil
      @id = @settings.redis.incr("jobs.next.id")
      @settings.redis.lpush("jobs", @id)
      puts "i got id " + @id.to_s
    end
    @id
  end

  def self.var_names
    ['spreadsheet', 'worksheet', 'status', 'results']
  end
  
  def save
    @id = get_id
    Job.var_names.each {|name| @settings.redis.hset("jobs:#{@id}", name, instance_variable_get("@#{name}"))}
  end

  def exec()

    source = GDriveTestSource.new(@spreadsheet, @worksheet, @settings.username, @settings.password)
    source.update_status("Running")    
    source.reset_spreadsheet()

    @status = "Running"
    save

    begin
      puts "here goes.."
      tester = Tester.new
      @results = tester.run(source)
      @status = "Finished"
    rescue Exception => e  
      puts e.backtrace.inspect  
      @results = e.message
      @status = "Failed"
    rescue Errno::ETIMEDOUT
      @results = "ETIMEDOUT error"
      @status = "Failed"
    end
        
    save

    source.update_spreadsheet(@results)

    # tr = TestResult.new(@id, results.to_json, @settings)
    # tr.save

    source.update_status("Finished at " + Time.now.to_s)

  end

  def self.perform(id)
    job = Job.load(id)
    job.exec
  end

end
