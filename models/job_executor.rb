module Sprat
  class JobExecutor

    def initialize(store)
      @writers = [store]
    end


    def execute(job)

      source = job.source

      @writers << Sprat::RemoteWriter.new(source.get_worksheet) unless job.local?

      test_config = Sprat::TestConfig.new(source.sheet)

      results = []
      job.status = "Running"
      job.started_at = Time.now

      @writers.each {|writer| writer.save(job, results)}

      begin
        api = Sprat::API.new(job.host, test_config.fetch('api'), test_config.fetch('apikey'))
        tests = Sprat::TestFactory.new(source.sheet, test_config).tests
        tests.each do |test|
          results << test.exec(api)
        end
        job.set_status(results)
      rescue => e
        job.status = "FAIL (" + e.message + ")"
        job.reason = e.message + e.backtrace.inspect
      end

      job.finished_at = Time.now

      @writers.each {|writer| writer.save(job, results)}

    end

  end
end