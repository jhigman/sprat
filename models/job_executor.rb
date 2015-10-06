module Sprat
  class JobExecutor

    def initialize(store)
      @store = store
    end


    def execute(job)

      source = job.source

      job.status = "Running"
      job.started_at = Time.now

      @store.save_job(job)

      unless job.local?
        source.save_job(job)
        source.save_results([])
      end

      api = source.get_api(job.host)
      tests = source.get_tests

      results = []

      begin
        tests.each do |test|
          results << test.exec(api)
        end
        job.set_status(results)
      rescue => e
        job.status = "FAIL (" + e.message + ")"
        job.reason = e.message + e.backtrace.inspect
      end

      job.finished_at = Time.now

      @store.save_job(job)
      @store.save_results(job, results)

      unless job.local?
        source.save_job(job)
        source.save_results(results)
      end

    end

  end
end