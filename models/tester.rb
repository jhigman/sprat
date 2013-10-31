module Sprat
  class Tester

    def initialize(app_settings = SpratTestRunner.settings)
      @settings = app_settings
      @results = []
    end

    def get_results
      @results
    end

    def get_failures
      @results.select { |result| result['result'] != 'PASS' }
    end

    def has_failures?
      failures = get_failures
      return failures.size > 0
    end

    def status
      if has_failures?
        return "FAIL (" + get_failures.size.to_s + " errors)"
      else
        return "PASS"
      end
    end

    def reason
      if has_failures?
        return "There were " + get_failures.size.to_s + " test failures"
      else
        return "There were " + get_results.size.to_s + " test passes"
      end
    end

    def run(source, host)
      api = source.get_api(host)
      tests = source.get_tests
      tests.each do |test|
        @results << test.exec(api)      
      end
    end

  end
end