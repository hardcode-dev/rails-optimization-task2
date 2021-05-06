# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../task-2'

class TestMemory < Minitest::Test
  MEMORY_LIMIT = 20

  def test_result
    work('benchmarks/demo_data/data_large.txt')
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    assert_operator memory, :<=, MEMORY_LIMIT, "Memory test failed: #{memory} > #{MEMORY_LIMIT}"
  end
end

# Run options: --seed 166
#
# # Running:
#
# MEMORY USAGE: 16 MB
#   .
#
#   Finished in 11.683115s, 0.0856 runs/s, 0.0856 assertions/s.
#
# 1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
