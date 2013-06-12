class TestResult

  attr_accessor :job_id, :results_json

  def initialize(job_id, results_json, app_settings = GDocTestRunner.settings)
    @job_id = job_id
    @results_json = results_json
    @settings = app_settings
  end

  def save
    @settings.redis.set("result-#{@job_id}", @results_json)
    @settings.redis.sadd("all-results", @job_id)
  end

end
