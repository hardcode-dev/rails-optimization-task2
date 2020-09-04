require 'minitest/autorun'
require_relative 'task-2-improved'

require 'json'

class TestMe < Minitest::Test
  def setup
    `head -n 100000 data_large.txt > data100000.txt`
  end

  def test_result
    service = ReportGenerator.new(input: 'data100000.txt', output: 'result.json')
    service.work
    assert_equal 15 - service.memory_usage > 0, true
  end
end