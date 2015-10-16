module Sprat
  class Sheet

    def initialize(spreadsheet, worksheet, settings = SpratTestRunner.settings)
      @spreadsheet = spreadsheet
      @worksheet = worksheet
      @settings = settings
    end

    def session
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

    def sheet
      if !@ws
        doc = session.spreadsheet_by_title(@spreadsheet)
        @ws = doc.worksheet_by_title(@worksheet)
      end
      @ws
    end

    def num_rows
      sheet.num_rows
    end

    def get(row, col)
      sheet[row, col]
    end

    def set(row, col, value)
      if sheet[row, col] != value
        sheet[row, col] = value
      end
    end

    def row(idx)
      if idx <= num_rows
        (1..sheet.num_cols).map{|n| get(idx,n)}
      end
    end

    def save
      retries = 0
      while retries < 3
        begin
          sheet.save
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