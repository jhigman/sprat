module Sprat
  class Sheet

    def initialize(spreadsheet, worksheet, settings = SpratApp.settings)
      @spreadsheet = spreadsheet
      @worksheet = worksheet
      @settings = settings
    end

    def sheet
      @ws ||= Sprat::Book.new(@spreadsheet, @settings).sheet(@worksheet)
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