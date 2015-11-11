module Sprat
  class Job

    @queue = :test_jobs

    attr_accessor :id, :spreadsheet, :worksheet, :host, :local, :status, :reason, :created_at, :started_at, :finished_at

    def initialize(store = nil, source = nil)
      @store = store
      @source = source
    end

    def store
      @store ||= SpratTestRunner.settings.store
    end

    def source
      @source ||= Sprat::Source.new(Sprat::Sheet.new(spreadsheet, worksheet))
    end

    def local?
      @local.to_s != "0"
    end

    def time_to_complete
      if @started_at && @finished_at
        diff = Time.parse(@finished_at) - Time.parse(@started_at)
        diff.to_i.to_s + " secs"
      end
    end

    def get_failures(results)
      results.select{|result| result.result != 'PASS'}
    end

    def set_status(results)
      @status = get_failures(results).empty? ?  "PASS" : "FAIL (" + get_failures(results).size.to_s + " errors)"
    end


    def exec

      @status = "Running"
      @started_at = Time.now

      store.save_job(self)

      unless local?
        source.save_job(self)
        source.save_results([])
      end

      api = source.get_api(host)
      tests = source.tests

      results = []

      begin
        tests.each do |test|
          results << test.exec(api)
        end
        set_status(results)
      rescue => e
        @status = "FAIL (" + e.message + ")"
        @reason = e.message + e.backtrace.inspect
      end

      @finished_at = Time.now

      store.save_job(self)
      store.save_results(self, results)

      unless local?
        source.save_job(self)
        source.save_results(results)
      end

    end

    def to_json
      JSON.dump ({
        id: id,
        spreadsheet: spreadsheet,
        worksheet: worksheet,
        host: host,
        local: local,
        status: status,
        reason: reason,
        created_at: created_at,
        started_at: started_at,
        finished_at: finished_at,
      })
    end

    def self.from_json(json)
      data = JSON.load(json)
      job = self.new
      job.id = data['id']
      job.spreadsheet = data['spreadsheet']
      job.worksheet = data['worksheet']
      job.host = data['host']
      job.local = data['local']
      job.status = data['status']
      job.reason = data['reason']
      job.created_at = data['created_at']
      job.started_at = data['started_at']
      job.finished_at = data['finished_at']
      job
    end

    def self.perform(id)
      job = SpratTestRunner.settings.store.load_job(id)
      job.exec
    end

  end
end