module Sprat
  class TestFactory

    def initialize(rows, config)
      @rows = rows
      @config = config
    end

    def split_to_array(str, sep = ',')
      str.split(sep).map(&:strip)
    end

    def headers
      unless @headers
        index = @rows.index{|row| row[0] && row[0].downcase == 'tests'}
        @headers = index ? @rows[index] : []
      end
      @headers.map(&:downcase)
    end

    def get_inputs(row)
      inputs = {}
      headers.each_with_index do |name, index|
        if @config.fetch('parameters').include?(name)
          inputs[name] = row[index]
        end
      end
      inputs
    end


    def get_outputs(row)
      outputs = []
      ignoreable = ['tests', 'result', 'reason'] + @config.fetch('parameters', []) + @config.fetch('ignore', [])
      headers.each_with_index do |name, index|
        if !ignoreable.include?(name)
          path = @config.fetch(name, name)
          outputs << { 'label' => name, 'path' => path, 'value' => row[index] }
        end
      end
      outputs
    end


    def tests
      first = @rows.index{|row| row[0] && row[0].downcase == 'tests'} + 1
      index = first
      tests = []
      while index < @rows.size
        row = @rows[index]
        tests << Sprat::Test.new((index - first + 1), get_inputs(row), get_outputs(row))
        index += 1
      end
      tests
    end

  end
end