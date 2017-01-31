module Sprat
  class JobExecutor

    def initialize(source, api)
      @source = source
      @api = api
    end

    def status_message(results)
      failures = results.select(&:failed?)
      failures.empty? ? "PASS" : "FAIL (#{failures.size} errors)"
    end


    def exec(job)

      job.update!(status: 'Running', started_at: Time.now)

      @source.write(job) unless job.local

      tests = @source.tests

      begin
        tests.each do |test|
          result = test.exec(@api)
          job.results << result
          result.save!
        end
        job.status = status_message(job.results)
        job.reason = ''
      rescue => e
        job.status = "FAIL (#{e.message})"
        job.reason = e.message + e.backtrace.inspect
      end

      job.finished_at = Time.now
      job.save!

      @source.write(job) unless job.local

    end

  end
end