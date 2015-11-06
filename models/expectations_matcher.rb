module Sprat
  class ExpectationsMatcher

    def self.create(response)
      if response.instance_of?(Array) && response.all? {|r| r.instance_of?(String) || r.instance_of?(Fixnum) || r.instance_of?(Float)}
         ExpectationsMatcherArray.new(response)
       else
        ExpectationsMatcherJson.new(response)
      end
    end

  end
end