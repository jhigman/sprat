module Sprat
  class Job

    include DataMapper::Resource

    property :id,           Serial
    property :spreadsheet,  String
    property :worksheet,    String
    property :host,    String
    property :local,    Boolean
    property :status,    String
    property :reason,    String
    property :created_at,    DateTime
    property :started_at,    DateTime
    property :finished_at,    DateTime

    has n, :results

    @queue = :test_jobs

    def initialize(source = nil)
      @source = source
    end

    def source
      @source ||= Sprat::Source.new(Sprat::Sheet.new(spreadsheet, worksheet))
    end

    def local?
      local.to_s != "0"
    end

    def time_to_complete
      if self.started_at && self.finished_at
        diff = self.finished_at - self.started_at
        (diff * 24 * 60 * 60).to_i.to_s + " secs"
      end
    end

    def get_failures(results)
      results.select{|result| result.result != 'PASS'}
    end

    def set_status(results)
      self.status = get_failures(results).empty? ?  "PASS" : "FAIL (#{get_failures(results).size} errors)"
    end


    def exec

      self.status = 'Running'
      self.started_at = Time.now

      save!

      unless local?
        source.save_job(self)
        source.save_results([])
      end

      api = source.get_api(host)
      tests = source.tests

      begin
        tests.each do |test|
          result = test.exec(api)
          self.results << result
          self.save!
        end
        set_status(self.results)
      rescue => e
        self.status = "FAIL (#{e.message})"
        self.reason = e.message + e.backtrace.inspect
      end

      self.finished_at = Time.now

      save!

      unless local?
        source.save_job(self)
        source.save_results(self.results)
      end

    end

    def self.perform(id)
      job = Sprat::Job.get!(id)
      job.exec
    end

  end
end