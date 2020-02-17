require './task-2'
require 'json'
require 'minitest/autorun'

class TestMe < Minitest::Test
  def test_memory_usage
    assert_operator 20, :>=, work('data_large.txt')
  end
end