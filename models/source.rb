module Sprat
  class Source

    SKIP_COLUMNS = 3
    BATCH_SIZE = 200

    def initialize(sheet)
      @sheet = sheet
    end

    def get_api(host = nil)
      api_url = get('api')
      api_key = get('apikey')
      Sprat::API.new(host, api_url, api_key)
    end

    def inputs(row, headers, parameters)
      inputs = {}
      parameters.each do |parameter|
        if idx = headers.map(&:downcase).find_index(parameter.downcase)
          inputs[parameter] = row[idx]
        end
      end
      inputs
    end

    def outputs(row, headers, ignore_names, header_paths)
      outputs = []
      headers.each_with_index do |header, idx|
        unless ignore_names.include?(header.downcase)
          outputs << { 'label' => header, 'path' => header_paths[header], 'value' => row[idx] }
        end
      end
      outputs
    end

    def paths(headers)
      header_paths = {}
      headers.each do |header|
        header_paths[header] = get(header, header)
      end
      header_paths
    end

    def tests
      tests = []
      if idx = index("tests")
        headers = @sheet.row(idx)
        test_id = 1
        parameters = get_array("parameters")
        ignore_names = (['tests','result','reason'] + get_array('ignore') + parameters).map(&:downcase)
        header_paths = paths(headers)
        while (row = @sheet.row(idx + test_id))
          tests << Sprat::Test.new(test_id, inputs(row, headers, parameters), outputs(row, headers, ignore_names, header_paths))
          test_id += 1
        end
      end
      tests
    end

    def index(name)
      idx = 1
      while idx <= @sheet.num_rows do
        return idx if @sheet.get(idx,1).downcase == name.downcase
        idx +=1
      end
    end

    def get(name, default = nil)
      if idx = index(name)
        @sheet.get(idx, 2)
      else
        default
      end
    end

    def get_array(name)
      if values = get(name)
        values.split(',').map(&:strip)
      end
    end

    def set(name, value)
      if idx = index(name)
        @sheet.set(idx, 2, value)
      end
    end


    def reset_spreadsheet()
      offset = index('tests') + 1
      while offset <= @sheet.num_rows do
        @sheet.set(offset, 2, "")
        @sheet.set(offset, 3, "")
        offset += 1
        if (offset % BATCH_SIZE) == 0
          @sheet.save
        end
      end
      @sheet.save
    end

    def update_spreadsheet(test_results)
      offset = index('tests')
      test_results.each do |result|
        row = result.id
        @sheet.set(offset + row, 2, result.result)
        @sheet.set(offset + row, 3, result.reason)
        if (row % BATCH_SIZE) == 0
          @sheet.save
        end
      end
      @sheet.save
    end


    def save_job(job)
      set("status", job.status)
      set("started at", job.started_at.to_s)
      set("finished at", job.finished_at.to_s)
      @sheet.save
    end

    def save_results(results = [])
      results.empty? ? reset_spreadsheet : update_spreadsheet(results)
    end

  end
end
