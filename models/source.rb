class Source

  SKIP_COLUMNS = 3

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
    # puts "Getting worksheet..."
    if !@ws
      doc = get_session.spreadsheet_by_title(@spreadsheet)
      @ws = doc.worksheet_by_title(@worksheet)
    end
    return @ws
  end

  def get_api
    api_url = get_config('api')
    api_key = get_config('apikey')
    api = API.new(api_url, api_key)
  end

  def get_parameter_names
    names = get_config('parameters').split(',').map(&:strip).map(&:downcase)
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
    param_names = get_parameter_names
    outputs = Hash.new
    headers.each_with_index do |header, index|
      if !param_names.include? header
        outputs[header] = row[SKIP_COLUMNS+index]
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
      tests << Test.new(index, inputs, outputs)
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
      headers << sheet[offset, i].downcase
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
    i = 1
    while i <= sheet.num_rows  do
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

  def update_status(msg)    
    sheet = get_worksheet
    set_config('status', msg)
    sheet.save
  end

  def reset_spreadsheet()

    puts "Resetting spreadsheet..."

    ws = get_worksheet

    offset = get_config_row('tests')

    offset += 1

    while offset < ws.max_rows do
      ws[offset, 2] = ""
      ws[offset, 3] = ""
      offset += 1
    end
    ws.save

  end

  def update_spreadsheet(test_results)

    puts "Updating spreadsheet with " + test_results.length.to_s + " test results.." 

    ws = get_worksheet

    offset = get_config_row('tests')

    # NB test IDs start from 1
    test_results.each do |result|
      ws[offset + result['id'].to_i, 2] = result['result']
      ws[offset + result['id'].to_i, 3] = result['reason']
    end
    ws.save

  end

  # def get_local_csv_path
  #   if !@local_csv_path
  #     @local_csv_path = get_gdrive_spreadsheet_as_csv()
  #     raise "get_gdrive_spreadsheet failed" unless @local_csv_path
  #   end
  #   return @local_csv_path 
  # end

  # def get_meta_from_local
  #   local_csv_path = get_local_csv_path
  #   csv_contents = CSV.read(local_csv_path)
  #   meta = get_meta_from_csv(csv_contents)
  # end

  # def get_tests_from_local
  #   local_csv_path = get_local_csv_path
  #   csv_contents = CSV.read(local_csv_path)
  #   tests = get_tests_from_csv(csv_contents)
  # end


  # def get_gdrive_spreadsheet_as_csv()

  #   puts "Getting spreadsheet..."

  #   csv_path = "/tmp/#{@spreadsheet}.csv"

  #   doc = get_session.spreadsheet_by_title(@spreadsheet)

  #   ss = doc.worksheets

  #   puts ss.inspect

  #   # doc.export_as_file csv_path, "csv"
  #   ss.export_as_file csv_path, "csv"

  #   return csv_path

  # end

  # def get_meta_from_csv(csv_contents)

  #   puts "Parsing spreadsheet for meta..."

  #   loaded = false

  #   meta = Hash.new

  #   while !loaded do
  #     row = csv_contents.shift
  #     if row[0] == "Config" 
  #       row = csv_contents.shift
  #       meta['api'] = row[1]
  #       loaded = true
  #     end
  #   end
  
  #   return meta
  # end


  # def get_tests_from_csv(csv_contents)

  #   puts "Parsing spreadsheet for tests..."

  #   loaded = false

  #   tests = []

  #   while !loaded do
  #     row = csv_contents.shift

  #     if row[0] == "Tests"

  #       # skip the headers
  #       row = csv_contents.shift

  #       # start reading test rows
  #       row = csv_contents.shift
  #       while row do
  #         tests << row
  #         row = csv_contents.shift
  #       end
  #       # return tests
  #       loaded = true
  #     end
  #   end

  #   return tests
  # end

end
