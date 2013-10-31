module Sprat
  class Job

    @queue = :test_jobs
    
    attr_accessor :settings, :id, :spreadsheet, :worksheet, :host, :local, :status, :reason, :results, :created

    def initialize(app_settings = SpratTestRunner.settings)
      @settings = app_settings
      @status = "Pending"
      @results = []
    end

    def self.var_names
      ['spreadsheet', 'worksheet', 'host', 'local', 'status', 'reason', 'results', 'created']
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
        @settings.redis.hset("jobs:#{@id}", name, value.to_s)
      end
    end

    def local?
      return @local.to_s != "0" 
    end

    def exec()

      source = Source.new(@spreadsheet, @worksheet, @settings.username, @settings.password)

      unless local?
        source.update_status("Running", "Status")
        source.update_status(Time.now.to_s, "Started At")    
        source.update_status("", "Finished At")    
        source.reset_spreadsheet()
      end

      @results = []
      @status = "Running"
      save

      tester = Tester.new(@settings)

      resultsArray = []

      begin
        tester.run(source, host)
        @status = tester.status
        @reason = tester.reason
      rescue => e
        @status = "FAIL (" + e.message + ")"
        @reason = e.message + e.backtrace.inspect
      end

      @results = JSON.generate(tester.get_results)
      save

      unless local?
        source.update_spreadsheet(tester.get_results)
        source.update_status(@status, "Status")
        source.update_status(Time.now.to_s, "Finished At")
      end

    end

    def self.perform(id)
      job = Job.load(id)
      job.exec
    end

  end
end