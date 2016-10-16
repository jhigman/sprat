describe Sprat::JobExecutor do

  it "should exec job" do

    result = Sprat::Result.new

    api = double(:api)

    test = double(:test)
    expect(test).to receive(:exec).with(api).and_return(result)

    source = double(:source)
    expect(source).to receive(:get_api).with('google.com').and_return(api)
    expect(source).to receive(:tests).and_return([test])

    job = Sprat::Job.new(local: true, host: 'google.com')

    Sprat::JobExecutor.new(source).exec(job)

    expect(job.results).to eq([result])

  end

  it "should set status" do

    api = double(:api)

    test1 = double(:test)
    test2 = double(:test)

    result1 = Sprat::Result.new(result: 'PASS')
    result2 = Sprat::Result.new(result: 'FAIL', reason: 'not a good reason')

    expect(test1).to receive(:exec).with(api).and_return(result1)
    expect(test2).to receive(:exec).with(api).and_return(result2)

    source = double(:source)
    expect(source).to receive(:get_api).with('google.com').and_return(api)
    expect(source).to receive(:tests).and_return([test1, test2])

    job = Sprat::Job.new(local: true, host: 'google.com')
    Sprat::JobExecutor.new(source).exec(job)

    expect(job.status).to eql('FAIL (1 errors)')

  end

end