require_relative '../../app.rb'

describe Sprat::Source do

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

  it "should extract config" do

    rows = [
      ['',''],
      ['parameters', 'One, Two'],
      ['ignore', 'comment'],
      ['',''],
      ['Tests','Result','Reason','one','two','first','second'],
    ]

    sheet = DummySheet.new(rows)

    source = Sprat::Source.new(sheet)

    expect(source.get_array("parameters")).to eql(['One', 'Two'])
    expect(source.get_array("ignore")).to eql(['comment'])

  end

  it "should use case of parameter list for inputs" do

    rows = [
      ['',''],
      ['parameters', 'one, two'],
      ['ignore', 'comment'],
      ['',''],
      ['Tests','Result','Reason','comment','one','TWO','first','second'],
      ['','','','checking for edge condition','abc','def','',''],
      ['','','','another alpha test','xyz','stu','',''],
    ]

    sheet = DummySheet.new(rows)

    source = Sprat::Source.new(sheet)
    expect(source.tests.size).to eql(2)

    test = source.tests[0]
    expect(test.inputs["one"]).to eql("abc")
    expect(test.inputs["two"]).to eql("def")

    test = source.tests[1]
    expect(test.inputs["one"]).to eql("xyz")
    expect(test.inputs["two"]).to eql("stu")

  end


end