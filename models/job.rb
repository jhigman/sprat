module Sprat
  class Job

    include DataMapper::Resource

    property :id,           Serial
    property :spreadsheet,  String
    property :worksheet,    String
    property :host,         String
    property :local,        Boolean
    property :status,       String
    property :reason,       String
    property :created_at,   DateTime
    property :started_at,   DateTime
    property :finished_at,  DateTime

    has n, :results

    @queue = :test_jobs

    def time_to_complete
      if self.started_at && self.finished_at
        diff = self.finished_at - self.started_at
        (diff * 24 * 60 * 60).to_i.to_s + " secs"
      end
    end

    def self.perform(id)
      job = Sprat::Job.get!(id)
      source = Sprat::Source.new(Sprat::Sheet.new(job.spreadsheet, job.worksheet))
      api = Sprat::API.new(job.host)
      Sprat::JobExecutor.new(source, api).exec(job)
    end

  end
end