# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../task-2'

class TestMe < Minitest::Test
  def test_result
    memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work('tmp/data_100000.txt')
    memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    total_memory_usage = memory_usage_after - memory_usage_before
    puts "Total memory usage: #{total_memory_usage} MB"
    assert_operator total_memory_usage, :<=, 20
  end
end
