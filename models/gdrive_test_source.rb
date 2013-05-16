class GDriveTestSource

  def initialize(docname, username, password)
    @docname = docname
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

  def get_local_csv_path
    if !@local_csv_path
      @local_csv_path = get_gdrive_spreadsheet_as_csv()
      raise "get_gdrive_spreadsheet failed" unless @local_csv_path
    end
    return @local_csv_path 
  end

  def get_meta
    local_csv_path = get_local_csv_path
    csv_contents = CSV.read(local_csv_path)
    meta = get_meta_from_csv(csv_contents)
  end

  def get_tests
    local_csv_path = get_local_csv_path
    csv_contents = CSV.read(local_csv_path)
    tests = get_tests_from_csv(csv_contents)
  end


  def get_gdrive_spreadsheet_as_csv()

    puts "Getting spreadsheet..."

    csv_path = "/tmp/#{@docname}.csv"

    doc = get_session.spreadsheet_by_title(@docname)
    doc.export_as_file csv_path, "csv"

    return csv_path

  end

  def reset_spreadsheet()

    puts "Resetting spreadsheet..."

    ws = get_session.spreadsheet_by_title(@docname).worksheets[0]

    offset = 1
    while offset < ws.max_rows do
      if ws[offset, 1] == "Tests"
        break
      end
      offset += 1
    end

    offset += 1

    while offset < ws.max_rows do
      ws[offset, 2] = ""
      ws[offset, 3] = ""
      offset += 1
    end
    ws.save

  end

  def update_spreadsheet(test_results)

    puts "Updating spreadsheet..."

    ws = get_session.spreadsheet_by_title(@docname).worksheets[0]

    offset = 1
    while offset < ws.max_rows do
      if ws[offset, 1] == "Tests"
        break
      end
      offset += 1
    end

    offset += 1

    test_results.each do |result|
      ws[result[:id].to_i+offset, 2] = result[:result]
      ws[result[:id].to_i+offset, 3] = result[:reason]
      ws.save
    end

  end

  def get_meta_from_csv(csv_contents)

    puts "Parsing spreadsheet for meta..."

    loaded = false

    meta = Hash.new

    while !loaded do
      row = csv_contents.shift
      if row[0] == "Config" 
        row = csv_contents.shift
        meta['api'] = row[1]
        loaded = true
      end
    end
  
    return meta
  end


  def get_tests_from_csv(csv_contents)

    puts "Parsing spreadsheet for tests..."

    loaded = false

    tests = []

    while !loaded do
      row = csv_contents.shift

      if row[0] == "Tests"

        # skip the headers
        row = csv_contents.shift

        # start reading test rows
        row = csv_contents.shift
        while row do
          tests << row
          row = csv_contents.shift
        end
        # return tests
        loaded = true
      end
    end

    return tests
  end

end
