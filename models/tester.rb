class Tester

  def initialize(app_settings = GDocTestRunner.settings)
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

  def run(source)
    api = source.get_api
    tests = source.get_tests
    tests.each do |test|
      @results << test.exec(api)      
    end
    return !has_failures(@results)
  end

end
