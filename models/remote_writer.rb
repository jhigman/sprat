module Sprat
  class RemoteWriter

    SKIP_COLUMNS = 3
    BATCH_SIZE = 200

    def initialize(worksheet)
      @worksheet = worksheet
    end



    def save(job, results = [])
      write_item("status", job.status)
      write_item("started at", job.started_at.to_s)
      write_item("finished at", job.finished_at.to_s)
      # results.empty? ? reset_spreadsheet : update_spreadsheet(results)
      write_remote
    end



    def write_item(name, value)
      idx = index(name)
      if idx
        @worksheet[idx,2] = value
      end
    end




    def write_remote
      retries = 0
      while retries < 3
        begin
          @worksheet.save
          return
        rescue => e
          puts "exception while saving : #{e.message}"
        end
        retries += 1
      end
      raise RuntimeError.new("Save failed after retries")
    end


    def index(name)
      idx = 1
      while idx <= @worksheet.num_rows do
        return idx if @worksheet[idx,1].downcase == name
        idx +=1
      end
    end



    # def get_config(name)
    #   sheet = get_worksheet
    #   tests_start_row = get_config_row('tests')
    #   i = 1
    #   while i <= tests_start_row  do
    #     label = sheet[i,1]
    #     if label.downcase == name.downcase
    #       return sheet[i,2]
    #     end
    #     i +=1
    #   end
    #   nil
    # end

    # def set_config(name, value)
    #   sheet = get_worksheet
    #   i = 1
    #   while i <= sheet.num_rows  do
    #     label = sheet[i,1]
    #     if label.downcase == name.downcase
    #       sheet[i,2] = value
    #       return
    #     end
    #     i +=1
    #   end
    # end

    # def get_config_row(name)
    #   sheet = get_worksheet
    #   i = 1
    #   while i <= sheet.num_rows  do
    #     label = sheet[i,1]
    #     if label.downcase == name.downcase
    #       return i
    #     end
    #     i +=1
    #   end
    #   nil
    # end

    # def update_status(msg, item = 'status')
    #   ws = get_worksheet
    #   set_config(item, msg)
    #   save(ws)
    # end

    # def set_cell(ws, row, col, val)
    #   current_val = ws[row, col]
    #   if current_val != val
    #     ws[row, col] = val
    #   end
    # end

    # def reset_spreadsheet()

    #   puts "Resetting worksheet '#{@worksheet}'..."

    #   ws = get_worksheet

    #   offset = get_config_row('tests')

    #   offset += 1

    #   while offset <= ws.num_rows do
    #     set_cell(ws, offset, 2, "")
    #     set_cell(ws, offset, 3, "")
    #     offset += 1

    #     if (offset % BATCH_SIZE) == 0
    #       puts "offset now #{offset}"
    #       save(ws)
    #     end

    #   end

    #   save(ws)

    # end

    # def update_spreadsheet(test_results)

    #   puts "Updating worksheet '#{@worksheet}' with " + test_results.length.to_s + " test results.."

    #   ws = get_worksheet

    #   offset = get_config_row('tests')

    #   # NB test IDs start from 1
    #   test_results.each do |result|

    #     row = result.id
    #     set_cell(ws, offset + row, 2, result.result)
    #     set_cell(ws, offset + row, 3, result.reason)

    #     if (row % BATCH_SIZE) == 0
    #       puts "results now #{row}"
    #       save(ws)
    #     end

    #   end

    #   save(ws)

    # end

    # def save_job(job)
    #   update_status(job.status, "Status")
    #   update_status(job.started_at.to_s, "Started At")
    #   update_status(job.finished_at.to_s, "Finished At")
    # end

    # def save_results(results = [])
    #   results.empty? ? reset_spreadsheet : update_spreadsheet(results)
    # end

  end
end