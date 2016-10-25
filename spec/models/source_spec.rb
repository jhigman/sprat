require_relative '../../app.rb'

describe Sprat::Source do

  class DummySheet

    attr_accessor :save_count

    def initialize(rows)
      @rows = rows
      @save_count = 0
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

    def save
      @save_count += 1
    end

  end

  it "creates expected test" do

    rows = [
      ['api', '/'],
      ['parameters', 'param1'],
      ['tests','result','reason','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new('/', params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "ignores case of column names" do

    rows = [
      ['api', '/'],
      ['parameters', 'param1'],
      ['TEsts','Result','REASON','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new('/', params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "uses case of parameter list for params" do

    rows = [
      ['api', '/'],
      ['parameters', 'PARAM1'],
      ['tests','result','reason','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'PARAM1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new('/', params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "uses paths for expectations if specified" do

    rows = [
      ['api', '/'],
      ['parameters', 'param1'],
      ['expectation1', '/some/path'],
      ['tests','result','reason','param1','expectation1'],
      ['','','','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => '/some/path', 'value' => '111' }]
    expected_test = Sprat::Test.new('/', params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "ignores specified columns" do

    rows = [
      ['api', '/'],
      ['parameters', 'param1'],
      ['ignore', 'comments'],
      ['tests','result','reason','comments','param1','expectation1'],
      ['','','','test whether it works','aaa','111'],
    ]

    source = Sprat::Source.new(DummySheet.new(rows))

    params = { 'param1' => 'aaa' }
    expectations = [{ 'label' => 'expectation1', 'path' => 'expectation1', 'value' => '111' }]
    expected_test = Sprat::Test.new('/', params, expectations)

    expect(source.tests).to eq([expected_test])

  end

  it "returns multiple tests" do

    rows = [
      ['api', '/'],
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


  it "clears results on origin if empty results written" do

    rows = [
      ['Tests','Result','Reason','param1','expectation1'],
      ['','PASS','','aaa','111'],
      ['','FAIL','did not match expectation','bbb','222'],
    ]

    sheet = DummySheet.new(rows)
    source = Sprat::Source.new(sheet)
    job = Sprat::Job.new

    source.write(job)

    expect(sheet.get(2,2)).to eql('')
    expect(sheet.get(2,3)).to eql('')

    expect(sheet.get(3,2)).to eql('')
    expect(sheet.get(3,3)).to eql('')

    expect(sheet.save_count).to eql(1)

  end

  it "writes job details and results" do

    rows = [
      ['status', ''],
      ['started at', ''],
      ['finished at', ''],
      ['Tests','Result','Reason','param1','expectation1'],
      ['','','','aaa','111'],
      ['','','','bbb','222'],
    ]

    sheet = DummySheet.new(rows)
    source = Sprat::Source.new(sheet)

    start = DateTime.now
    finish = DateTime.now + 1000
    result_1 = Sprat::Result.new(result: 'FAIL', reason: 'oops')
    result_2 = Sprat::Result.new(result: 'PASS', reason: '')
    job = Sprat::Job.new(status: 'FAILED', started_at: start, finished_at: nil, results: [result_1, result_2])

    source.write(job)

    expect(sheet.get(1,2)).to eql('FAILED')
    expect(sheet.get(2,2)).to eql(start.to_s)
    expect(sheet.get(3,2)).to eql('')
    expect(sheet.get(5,2)).to eql('FAIL')
    expect(sheet.get(5,3)).to eql('oops')
    expect(sheet.get(6,2)).to eql('PASS')
    expect(sheet.get(6,3)).to eql('')

    expect(sheet.save_count).to eql(1)

  end

end