class TestDataSource

  def initialize(docname, username, password)
    @docname = docname
    @username = username
    @password = password
    @session = nil
  end

  def get_session
    if !@session
      @session = GoogleDrive.login(@username, @password)
      raise "GDrive session failed" unless @session
    end
    return @session
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
end
