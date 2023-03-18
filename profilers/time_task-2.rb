require_relative '../task-2'
require 'benchmark'

def time(&block)
  time = Benchmark.realtime do
    block.call
  end

  puts "Completed in #{time.round(3)} ms"
end

time { work("data/data_large.txt") }

