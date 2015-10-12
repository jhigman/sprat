module Sprat
  class TestConfig

    def initialize(rows)
      @rows = rows
    end

    def split_to_array(str, sep = ',')
      str.split(sep).map(&:strip)
    end

    def config
      unless @config
        @config = {}
        @rows.each do |row|
          if row[0]
            @config[row[0].downcase] = row[1]
          end
        end
        ['parameters', 'ignore'].each do |key|
          if @config[key]
            @config[key] = split_to_array(@config[key])
          end
        end
      end
      @config
    end

    def fetch(key, default = nil)
      config[key] ? config[key] : default
    end

    def set(key, value)
    end

    def keys
    end

  end
end