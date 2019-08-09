require_relative '../task-2'
require 'minitest/autorun'
require 'minitest/benchmark'

class ParserBench < Minitest::Benchmark
  def bench_memory_on_out
    Parser.new.work('test/100000.txt')
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    assert_operator 25, :>, memory
  end
end
