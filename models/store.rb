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

    def save(job, results = [])
      job.id ||= next_id
      @redis.set("job:#{job.id}", YAML.dump(job))
      results.each do |result|
        @redis.lpush("job:#{job.id}:results", YAML.dump(result))
      end
      job
    end

    def save_job(job)
      job.id ||= next_id
      @redis.set("job:#{job.id}", YAML.dump(job))
      job
    end

    def load_job(id)
      yaml = @redis.get("job:#{id}")
      YAML.load(yaml) unless yaml.nil?
    end

    def load_jobs(start = max_id, number = 200)
      start.downto([start-number+1, 1].max).map{|id| load_job(id)}
    end

    def save_results(job, results)
      results.each do |result|
        @redis.lpush("job:#{job.id}:results", YAML.dump(result))
      end
    end

    def load_results(job)
      yamls = @redis.lrange("job:#{job.id}:results", 0, -1)
      yamls.map{|yaml| YAML.load(yaml)}.sort_by(&:id)
    end

    def clear
      @redis.flushall
    end

  end
end