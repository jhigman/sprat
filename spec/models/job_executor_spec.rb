describe Sprat::JobExecutor do

  it "show pass if all tests pass" do

    result = Sprat::Result.new(result: 'PASS')

    api = double(:api)

    test = double(:test)
    expect(test).to receive(:exec).with(api).and_return(result)

    source = double(:source)
    expect(source).to receive(:tests).and_return([test])

    job = Sprat::Job.create(local: true)

    Sprat::JobExecutor.new(source, api).exec(job)

    expect(job.status).to eq('PASS')
    expect(job.results).to eq([result])

  end

  it "shows fail if one test fails" do

    api = double(:api)

    test1 = double(:test)
    test2 = double(:test)

    result1 = Sprat::Result.new(result: 'PASS')
    result2 = Sprat::Result.new(result: 'FAIL', reason: 'not a good reason')

    expect(test1).to receive(:exec).with(api).and_return(result1)
    expect(test2).to receive(:exec).with(api).and_return(result2)

    source = double(:source)
    expect(source).to receive(:tests).and_return([test1, test2])

    job = Sprat::Job.create(local: true)
    Sprat::JobExecutor.new(source, api).exec(job)

    expect(job.status).to eql('FAIL (1 errors)')

  end

end