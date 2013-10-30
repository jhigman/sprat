module Sprat
  class Tester

    def initialize(app_settings = SpratTestRunner.settings)
      @settings = app_settings
      @results = []
    end

    def get_results
      @results
    end

    def has_failures(results)
      results.each do |result|
        if result['result'] != 'PASS'
          return true
        end
      end
      return false
    end

    def run(source, host)
      api = source.get_api(host)
      tests = source.get_tests
      tests.each do |test|
        @results << test.exec(api)      
      end
      return !has_failures(@results)
    end

  end
end