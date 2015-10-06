require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class JobTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  def test_exec

    RSpec::Mocks.with_temporary_scope do

      result1 = Sprat::Result.new(1, [], nil, nil, [])
      result2 = Sprat::Result.new(2, [], nil, nil, ['not a good response'])

      job = Sprat::Job.new
      job.set_status([result1, result2])

      assert_equal 'FAIL (1 errors)', job.status

    end

  end

end