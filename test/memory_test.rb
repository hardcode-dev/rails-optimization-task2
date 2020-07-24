# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../task-2'

class TestMe < Minitest::Test
  def memory_usage
    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end

  def test_result
    memory_usage_before= memory_usage
    work('tmp/data_80000.txt')
    memory_usage_after = memory_usage
    mem_usage = memory_usage_after - memory_usage_before
    puts "mem_usage: #{mem_usage} MB"
    assert_operator mem_usage, :<=, 45
  end
end
