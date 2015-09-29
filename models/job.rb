module Sprat
  class Job

    @queue = :test_jobs

    attr_accessor :settings, :id, :spreadsheet, :worksheet, :host, :local, :status, :reason, :created_at, :started_at, :finished_at

    def initialize(app_settings = SpratTestRunner.settings)
      @settings = app_settings
      @status = "Pending"
    end

    def self.var_names
      ['spreadsheet', 'worksheet', 'host', 'local', 'status', 'reason', 'created_at', 'started_at', 'finished_at']
    end

    def self.load(id)
      job = new
      job.id = id
      Job.var_names.each do |name|
        job.instance_variable_set("@#{name}", job.settings.redis.hget("job:#{job.id}", name))
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

    def save(source = nil)
      id = get_id
      Job.var_names.each do |name|
        @settings.redis.hset("job:#{id}", name, instance_variable_get("@#{name}").to_s)
      end

      if source && !local?
        source.update_status(@status, "Status")
        source.update_status(@started_at.to_s, "Started At")
        source.update_status(@finished_at.to_s, "Finished At")
        if @finished_at
          source.update_spreadsheet(get_results)
        else
          source.reset_spreadsheet()
        end
      end

    end

    def local?
      @local.to_s != "0"
    end


    def add_result(result)
      @settings.redis.sadd("job:#{@id}:results", JSON.generate(result))
    end

    def get_results
      @settings.redis.smembers("job:#{@id}:results").map{|r| JSON.parse(r)}.sort_by{|r| r['id']}
    end

    def get_failures
      get_results.select { |result| result['result'] != 'PASS' }
    end

    def status
      get_failures.size > 0 ?  "FAIL (" + get_failures.size.to_s + " errors)" : "PASS"
    end

    def reason
      get_failures.size > 0 ? "There were " + get_failures.size.to_s + " test failures" : "There were " + get_results.size.to_s + " test passes"
    end


    def exec()

      source = Source.new(@spreadsheet, @worksheet, @settings)

      @status = "Running"
      @started_at = Time.now

      save(source)

      begin
        api = source.get_api(host)
        source.get_tests.each do |test|
          add_result(test.exec(api))
        end
        @status = status
        @reason = reason
      rescue => e
        @status = "FAIL (" + e.message + ")"
        @reason = e.message + e.backtrace.inspect
      end

      @finished_at = Time.now

      save(source)

    end

    def self.perform(id)
      job = Job.load(id)
      job.exec
    end

  end
end