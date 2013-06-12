class Job

  @queue = :test_jobs
  
  attr_accessor :id, :spreadsheet, :worksheet, :local, :status, :reason, :results
  attr_accessor :settings 

  def initialize(app_settings = GDocTestRunner.settings)
    @settings = app_settings
    @status = "Pending"
  end

  def self.var_names
    ['spreadsheet', 'worksheet', 'local', 'status', 'reason', 'results']
  end
  
  def self.load(id)
    job = new
    job.id = id
    Job.var_names.each do |name|
      job.instance_variable_set("@#{name}", job.settings.redis.hget("jobs:#{job.id}", name))
    end
    job
  end

  def get_id
    if @id == nil
      @id = @settings.redis.incr("jobs.next.id")
      @settings.redis.lpush("jobs", @id)
    end
    @id
  end

  def save
    @id = get_id
    Job.var_names.each do |name|
      value = instance_variable_get("@#{name}")
      @settings.redis.hset("jobs:#{@id}", name, value.to_s) #unless value == nil
    end
  end

  def exec()

    source = GDriveTestSource.new(@spreadsheet, @worksheet, @settings.username, @settings.password)

    unless local
      source.update_status("Running")    
      source.reset_spreadsheet()
    end

    @status = "Running"
    save

    tester = Tester.new(@settings)

    resultsArray = []

    begin
      resultsArray = tester.run(source)
      @status = "Finished"
    rescue => e  
      @reason = e.message
      @status = "Failed"
    ensure
      # always set empty results
      @results = JSON.generate(resultsArray)
    end
        
    save

    unless local
      source.update_spreadsheet(resultsArray)
      source.update_status("Finished at " + Time.now.to_s)
    end

  end

  def self.perform(id)
    job = Job.load(id)
    job.exec
  end

end
