module Sprat
  class ExpectationsMatcherArray

    def initialize(response)
      @response = response
    end

    def is_true(val)
      ['y', 'yes', 'true', 't', '1'].include? val.to_s.downcase
    end

    def match(outputs)
      msgs = []
      if @response.empty? && outputs.any?{|output| !output['value'].empty?}
        msgs << "No results returned"
      else
        outputs.each do |output|
          key = output['path']
          expected = output['value']
          if is_true(expected)
            if !@response.include? key
              msgs << "#{key} not found"
            end
          else
            if @response.include? key
              msgs << "#{key} should not have been found"
            end
          end
          @response.delete(key)
        end
        if @response.size > 0
          msgs << "#{@response.join(",")} should not have been found"
        end
      end
      msgs
    end

  end
end