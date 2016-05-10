module Sprat
  class Store

    JOB_ID_KEY = "jobs.next.id"

    def initialize(redis)
      @redis = redis
    end

    def next_id
      @redis.incr(JOB_ID_KEY)
    end

    def max_id
      @redis.get(JOB_ID_KEY).to_i
    end

    def save_job(job)
      job.id ||= next_id
      @redis.set("job:#{job.id}", job.to_json)
      job
    end

    def load_job(id)
      json = @redis.get("job:#{id}")
      Sprat::Job.from_json(json) unless json.nil?
    end

    def load_jobs(start = max_id, number = 1000)
      start.downto([start-number+1, 1].max).map{|id| load_job(id)}
    end

    def save_result(job, result)
      @redis.lpush("job:#{job.id}:results", result.to_json)
    end

    def load_results(job)
      jsons = @redis.lrange("job:#{job.id}:results", 0, -1)
      jsons.map{|json| Sprat::Result.from_json(json)}.sort_by(&:id)
    end

    def clear
      @redis.flushall
    end

  end
end