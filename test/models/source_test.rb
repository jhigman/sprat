require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class SourceTest < Minitest::Test

  include RSpec::Mocks::ExampleMethods

  class DummySheet

    def initialize(rows)
      @rows = rows
    end

    def num_rows
      @rows.size
    end

    def get(row, col)
      @rows[row-1][col-1]
    end

    def set(row, col, val)
      @rows[row-1][col-1] = val
    end

    def row(idx)
      @rows[idx-1]
    end

  end

  def test_config

    rows = [
      ['',''],
      ['parameters', 'One, Two'],
      ['ignore', 'comment'],
      ['',''],
      ['Tests','Result','Reason','one','two','first','second'],
    ]

    sheet = DummySheet.new(rows)

    source = Sprat::Source.new(sheet)

    assert_equal ['one', 'two'], source.get_array("parameters")
    assert_equal ['comment'], source.get_array("ignore")

  end

  def test_tests

    rows = [
      ['',''],
      ['parameters', 'one, two'],
      ['ignore', 'comment'],
      ['',''],
      ['Tests','Result','Reason','comment','one','two','first','second'],
      ['','','','checking for edge condition','abc','def','',''],
      ['','','','another alpha test','xyz','stu','',''],
    ]

    sheet = DummySheet.new(rows)

    source = Sprat::Source.new(sheet)

    assert_equal 2, source.tests.size
    test = source.tests[0]
    assert_equal "abc", test.inputs["one"]
    assert_equal "def", test.inputs["two"]
    test = source.tests[1]
    assert_equal "xyz", test.inputs["one"]
    assert_equal "stu", test.inputs["two"]

  end


end