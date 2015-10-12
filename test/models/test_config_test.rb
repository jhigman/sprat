require 'minitest/autorun'
require 'rspec/mocks'

require_relative '../../app.rb'

class TestConfigTest < Minitest::Test

  def test_get_config

    rows = []
    rows << ['parameters', 'country, region']
    rows << ['ignore', 'comment']
    rows << ['apikey', '123']
    rows << []
    rows << ['Tests', 'Result', 'Reason', 'country', 'region', 'disease' ]

    config = Sprat::TestConfig.new(rows)

    assert_equal ['comment'], config.fetch('ignore')
    assert_equal ['country', 'region'], config.fetch('parameters')
    assert_equal '123', config.fetch('apikey')

  end

end