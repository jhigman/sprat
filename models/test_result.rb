class TestResult

  attr_accessor :job_id, :results_json

  def initialize(job_id, results_json)
    @job_id = job_id
    @results_json = results_json
  end

  def save
    $redis.set("result-#{@job_id}", @results_json)
    $redis.sadd("all-results", @job_id)
  end

end
