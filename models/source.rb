module Sprat
  class Source

    BATCH_SIZE = 200

    def initialize(sheet)
      @sheet = sheet
    end


    def tests
      tests = []
      if config['tests']
        idx = config['tests'][:row] + 1
        while (row = @sheet.row(idx))
          tests << Sprat::Test.new(inputs(row), outputs(row))
          idx += 1
        end
      end
      tests
    end


    def get_api(host = nil)
      api_url = get('api')
      api_key = get('apikey')
      Sprat::API.new(host, api_url, api_key)
    end



    def write(job)
      set('status', job.status)
      set('started at', job.started_at.to_s)
      set('finished at', job.finished_at.to_s)
      write_results(job.results)
    end


    private


    def config
      @config ||= parse(@sheet)
    end


    def parse(sheet)
      test_config = {}
      idx = 1
      while (idx <= sheet.num_rows) do
        name = sheet.get(idx,1)
        unless name.strip.empty?
          case name.downcase
          when 'tests'
            test_config['tests'] = {value: sheet.row(idx), row: idx}
            break
          when 'parameters'
            test_config['parameters'] = {value: to_array(sheet.get(idx,2)), row: idx}
          when 'ignore'
            test_config['ignore'] = {value: to_array(sheet.get(idx,2)), row: idx}
          else
            test_config[name.downcase] = {value: sheet.get(idx,2), row: idx}
          end
        end
        idx += 1
      end
      test_config
    end


    def inputs(row)
      inputs = {}
      headers = get('tests')
      parameters = get('parameters')
      parameters.each do |parameter|
        if idx = headers.map(&:downcase).find_index(parameter.downcase)
          inputs[parameter] = row[idx]
        end
      end
      inputs
    end

    def outputs(row)
      outputs = []
      headers = get('tests')
      exclude = (['tests','result','reason'] + get('parameters') + get('ignore',[])).map(&:downcase)
      headers.each_with_index do |header, idx|
        unless exclude.include?(header.downcase)
          outputs << { 'label' => header, 'path' => get(header, header), 'value' => row[idx] }
        end
      end
      outputs
    end


    def get(name, default = nil)
      if config[name.downcase]
        config[name.downcase][:value]
      else
        default
      end
    end

    def set(name, value)
      if config[name.downcase]
        @sheet.set(config[name.downcase][:row], 2, value)
      end
    end


    def to_array(str)
      str.split(',').map(&:strip)
    end


    def write_results(results = [])
      offset = config['tests'][:row]
      count = results.empty? ? (@sheet.num_rows - offset) : results.size
      idx = 0
      while (idx < count)
        result = results[idx]
        status = result ? result.result : ''
        reason = result ? result.reason : ''
        @sheet.set(offset + 1 + idx, 2, status)
        @sheet.set(offset + 1 + idx, 3, reason)
        if idx > 0 && (idx % BATCH_SIZE) == 0
          @sheet.save
        end
        idx += 1
      end
      @sheet.save
    end

  end
end
