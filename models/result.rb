module Sprat
  class Result

    include DataMapper::Resource

    property :id,       Serial
    property :uri,      Text
    property :params,   Text
    property :response, Text
    property :result,   Text
    property :reason,   Text

    belongs_to :job

    def passed?
      result == 'PASS'
    end

    def failed?
      result == 'FAIL'
    end

  end
end