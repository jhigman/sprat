class Job

  def initialize(docname, settings)
    @docname = docname
    @settings = settings
  end

  def exec()

    source = GDriveTestSource.new(@docname, @settings.username, @settings.password)
    tester = ApiTest.new(source, @settings.apikey)

    return tester.test_malaria_prevalence()

  end

end
