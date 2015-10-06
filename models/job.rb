module Sprat
  class Job

    @queue = :test_jobs

    attr_accessor :id, :spreadsheet, :worksheet, :host, :local, :status, :reason, :created_at, :started_at, :finished_at

    def source
      Sprat::Source.new(spreadsheet, worksheet)
    end

    def local?
      @local.to_s != "0"
    end

    def get_failures(results)
      results.select{|result| result.result != 'PASS'}
    end

    def set_status(results)
      @status = get_failures(results).empty? ?  "PASS" : "FAIL (" + get_failures(results).size.to_s + " errors)"
    end

    def self.perform(id)
      store = SpratTestRunner.settings.store
      job = store.load_job(id)
      JobExecutor.new(store).execute(job)
    end

  end
end