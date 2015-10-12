module Sprat
  class Source

    SKIP_COLUMNS = 3
    BATCH_SIZE = 200

    def initialize(spreadsheet, worksheet, settings = SpratTestRunner.settings)
      @spreadsheet = spreadsheet
      @worksheet = worksheet
      @settings = settings
      @session = nil
    end

    def get_session
      if !@session

        client = Google::APIClient.new(application_name: 'TestRunner', application_version: '0.0.1')

        google_client_email = @settings.google_client_email
        google_p12_file = @settings.google_p12_file
        google_p12_secret = @settings.google_p12_secret

        key = Google::APIClient::KeyUtils.load_from_pkcs12(
          google_p12_file,
          google_p12_secret
        )

        scopes = [
          'https://docs.google.com/feeds/',
          'https://www.googleapis.com/auth/drive',
          'https://spreadsheets.google.com/feeds/'
        ]

        asserter = Google::APIClient::JWTAsserter.new(
            google_client_email,
            scopes,
            key
        )

        client.authorization = asserter.authorize

        @session = GoogleDrive.login_with_oauth(client.authorization.access_token)

        raise "GDrive session failed" unless @session
      end
      @session
    end

    def get_worksheet
      if !@ws
        doc = get_session.spreadsheet_by_title(@spreadsheet)
        @ws = doc.worksheet_by_title(@worksheet)
      end
      @ws
    end

    def sheet
      get_worksheet.rows
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
      nil
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
      nil
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

        row = result.id
        set_cell(ws, offset + row, 2, result.result)
        set_cell(ws, offset + row, 3, result.reason)

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

    # def save_job(job)
    #   update_status(job.status, "Status")
    #   update_status(job.started_at.to_s, "Started At")
    #   update_status(job.finished_at.to_s, "Finished At")
    # end

    # def save_results(results = [])
    #   results.empty? ? reset_spreadsheet : update_spreadsheet(results)
    # end

    def save(job, results = [])
      update_status(job.status, "Status")
      update_status(job.started_at.to_s, "Started At")
      update_status(job.finished_at.to_s, "Finished At")
      results.empty? ? reset_spreadsheet : update_spreadsheet(results)
    end

  end
end