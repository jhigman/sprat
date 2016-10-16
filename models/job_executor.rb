module Sprat
  class JobExecutor

    def initialize(source)
      @source = source
    end

    def status_message(results)
      failures = results.select(&:failed?)
      failures.empty? ? "PASS" : "FAIL (#{failures.size} errors)"
    end


    def exec(job)

      job.status = 'Running'
      job.started_at = Time.now
      job.save!

      unless job.local
        @source.save_job(job)
        @source.save_results([])
      end

      api = @source.get_api(job.host)
      tests = @source.tests

      begin
        tests.each do |test|
          job.results << test.exec(api)
          job.save!
        end
        job.status = status_message(job.results)
      rescue => e
        job.status = "FAIL (#{e.message})"
        job.reason = e.message + e.backtrace.inspect
      end

      job.finished_at = Time.now
      job.save!

      unless job.local
        @source.save_job(job)
        @source.save_results(job.results)
      end

    end

  end
end