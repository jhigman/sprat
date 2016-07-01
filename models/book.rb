module Sprat
  class Book

    def initialize(spreadsheet, settings = SpratTestRunner.settings)
      @spreadsheet = spreadsheet
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

    def sheets
      session.spreadsheet_by_title(@spreadsheet).worksheets
    end

    def sheet(name)
      session.spreadsheet_by_title(@spreadsheet).worksheet_by_title(name)
    end


  end
end