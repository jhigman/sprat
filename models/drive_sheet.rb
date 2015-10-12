module Sprat
  class DriveSheet

    def initialize(spreadsheet, worksheet)
      @spreadsheet = spreadsheet
      @worksheet = worksheet
    end

    def sheet

      unless @sheet

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

        session = GoogleDrive.login_with_oauth(client.authorization.access_token)

        raise "GDrive session failed" unless session

        @sheet = session.spreadsheet_by_title(@spreadsheet).worksheet_by_title(@worksheet)

      end

      @sheet

    end

    def get(row, col)
      sheet[row][col]
    end

    def row
    end

    def num_rows
      sheet.num_rows
    end

  end
end