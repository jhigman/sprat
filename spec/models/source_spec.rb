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

  it "creates expected test" do

    rows = [
      ['parameters', 'param1'],
      ['tests','result','reason','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new(params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "ignores case of column names" do

    rows = [
      ['parameters', 'param1'],
      ['TEsts','Result','REASON','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new(params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "uses case of parameter list for params" do

    rows = [
      ['parameters', 'PARAM1'],
      ['tests','result','reason','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'PARAM1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }, ]
    expected_test = Sprat::Test.new(params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "ignores specified columns" do

    rows = [
      ['parameters', 'param1'],
      ['ignore', 'comments'],
      ['tests','result','reason','comments','param1','expectation1'],
      ['','','','test whether it works','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }, ]
    expected_test = Sprat::Test.new(params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "returns multiple tests" do

    rows = [
      ['parameters', 'param1'],
      ['Tests','Result','Reason','param1','expectation1'],
      ['','','','aaa','111'],
      ['','','','bbb','222'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    expect(source.tests.size).to eql(2)
    expect(source.tests[0].params['param1']).to eq('aaa')
    expect(source.tests[0].expectations[0]['value']).to eq('111')
    expect(source.tests[1].params['param1']).to eq('bbb')
    expect(source.tests[1].expectations[0]['value']).to eq('222')

  end


  it "writes values back to the origin" do

    rows = [
      [''],
      ['Started at', ''],
      ['Status', ''],
    ]

    sheet = DummySheet.new(rows)
    source = Sprat::Source.new(sheet)

    source.set('Started at', '2016-01-02')
    source.set('Status', 'Running')

    expect(sheet.get(2,2)).to eql('2016-01-02')
    expect(sheet.get(3,2)).to eql('Running')

  end

end