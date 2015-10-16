require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class JobTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  def test_exec

    api = Sprat::API.new
    result = Sprat::Result.new(1, [], '', '', '', '')

    test = Minitest::Mock.new
    test.expect(:exec, result, [api])

    store = Minitest::Mock.new
    store.expect(:save_job, [], [Sprat::Job])
    store.expect(:save_job, [], [Sprat::Job])
    store.expect(:save_results, [], [Sprat::Job, [result]])

    source = Minitest::Mock.new
    source.expect(:get_api, api, ['google.com'])
    source.expect(:tests, [test])

    api = MiniTest::Mock.new
    api.expect(:make_call, '', [{}])

    job = Sprat::Job.new(store, source)
    job.local = true
    job.host = 'google.com'

    job.exec

    store.verify
    source.verify

  end

  def test_set_status

    result1 = Sprat::Result.new(1, [], '', '', 'PASS', '')
    result2 = Sprat::Result.new(1, [], '', '', 'FAIL', 'not a good reason')

    job = Sprat::Job.new
    job.set_status([result1, result2])

    assert_equal 'FAIL (1 errors)', job.status

  end

end