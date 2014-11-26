module Sprat
  class Source

    SKIP_COLUMNS = 3
    BATCH_SIZE = 200

    def initialize(spreadsheet, worksheet, username, password)
      @spreadsheet = spreadsheet
      @worksheet = worksheet
      @username = username
      @password = password
      @session = nil
      @local_csv_path = nil
    end

    def get_session
      if !@session
        @session = GoogleDrive.login(@username, @password)
        raise "GDrive session failed" unless @session
      end
      return @session
    end

    def get_worksheet
      if !@ws
        doc = get_session.spreadsheet_by_title(@spreadsheet)
        @ws = doc.worksheet_by_title(@worksheet)
      end
      return @ws
    end

    def get_api(host = nil)
      api_url = get_config('api')
      api_key = get_config('apikey')
      api = Sprat::API.new(host, api_url, api_key)
    end

    def get_parameter_names
      params = get_config('parameters') || ""
      return params.split(',').map(&:strip)
    end

    def get_ignore_names
      ignore = get_config('ignore') || ""
      return ignore.split(',').map(&:strip)
    end

    def get_inputs(row, headers)
      param_names = get_parameter_names
      inputs = Hash.new
      headers.each_with_index do |header, index|
        if param_names.include? header
          inputs[header] = row[SKIP_COLUMNS+index]
        end
      end
      return inputs
    end

    def get_outputs(row, headers)
      ignore_names = get_ignore_names + get_parameter_names
      outputs = []
      headers.each_with_index do |header, index|
        if !ignore_names.include? header
          label = header
          value = row[SKIP_COLUMNS+index]
          path = get_config(header) || header
          outputs << { 'label' => label, 'path' => path, 'value' => value }
        end
      end
      return outputs
    end

    def get_tests
      tests = []
      headers = get_test_headers
      index = 1
      while (row = get_test_row(index))
        inputs = get_inputs(row, headers)
        outputs = get_outputs(row, headers)
        tests << Sprat::Test.new(index, inputs, outputs)
        index += 1
      end
      return tests
    end

    def get_test_headers
      headers = Array.new
      sheet = get_worksheet
      offset = get_config_row('tests')
      i = SKIP_COLUMNS + 1
      while i <= sheet.num_cols  do
        headers << sheet[offset, i]
        i +=1
      end
      return headers
    end

    def get_test_row(index)
      sheet = get_worksheet
      offset = get_config_row('tests')
      test_row = offset + index

      if test_row > sheet.num_rows
        return nil
      end

      ret = Array.new
      i = 1
      while i <= sheet.num_cols  do
        ret << sheet[test_row, i]
        i +=1
      end
      return ret
    end

    def get_config(name)
      sheet = get_worksheet
      tests_start_row = get_config_row('tests')
      i = 1
      while i <= tests_start_row  do
        label = sheet[i,1]
        if label.downcase == name.downcase
          return sheet[i,2]
        end
        i +=1
      end
      return nil
    end

    def set_config(name, value)
      sheet = get_worksheet
      i = 1
      while i <= sheet.num_rows  do
        label = sheet[i,1]
        if label.downcase == name.downcase
          sheet[i,2] = value
          return
        end
        i +=1
      end
    end

    def get_config_row(name)
      sheet = get_worksheet
      i = 1
      while i <= sheet.num_rows  do
        label = sheet[i,1]
        if label.downcase == name.downcase
          return i
        end
        i +=1
      end
      return nil
    end

    def update_status(msg, item = 'status')
      ws = get_worksheet
      set_config(item, msg)
      save(ws)
    end

    def set_cell(ws, row, col, val)
      current_val = ws[row, col]
      if current_val != val
        ws[row, col] = val
      end
    end

    def reset_spreadsheet()

      puts "Resetting worksheet '#{@worksheet}'..."

      ws = get_worksheet

      offset = get_config_row('tests')

      offset += 1

      while offset <= ws.num_rows do
        set_cell(ws, offset, 2, "")
        set_cell(ws, offset, 3, "")
        offset += 1

        if (offset % BATCH_SIZE) == 0
          puts "offset now #{offset}"
          save(ws)
        end

      end

      save(ws)

    end

    def update_spreadsheet(test_results)

      puts "Updating worksheet '#{@worksheet}' with " + test_results.length.to_s + " test results.."

      ws = get_worksheet

      offset = get_config_row('tests')

      # NB test IDs start from 1
      test_results.each do |result|

        row = result['id'].to_i
        set_cell(ws, offset + row, 2, result['result'])
        set_cell(ws, offset + row, 3, result['reason'])

        if (row % BATCH_SIZE) == 0
          puts "results now #{row}"
          save(ws)
        end

      end

      save(ws)

    end

    def save(ws)
      puts "saving.."
      retries = 0
      while retries < 3
        puts "retrying.." unless retries == 0
        begin
          ws.save
          puts "saved.."
          return
        rescue => e
          puts "exception while saving : #{e.message}"
        end
        retries += 1
      end
      raise RuntimeError.new("Save failed after retries")
    end


  end
end