require_relative '../app.rb'

RSpec.configure do |config|
  DataMapper.setup(:default, adapter: 'in_memory')
  DataMapper.finalize
end
