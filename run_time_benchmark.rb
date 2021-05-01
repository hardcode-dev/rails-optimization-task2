require_relative 'task-2'.freeze
require 'benchmark'

def work_with_benchmark
  # puts "На 1К строк: #{Benchmark.realtime { work('data_1K.txt') }}"
  # puts "На 10К строк: #{Benchmark.realtime { work('data_10K.txt') }}"
  puts "На 100К строк: #{Benchmark.realtime { work('data_100K.txt') }} с."
  # puts "На 1M строк: #{Benchmark.realtime { work('data_1M.txt') }} с."
  # puts "На data_large строк: #{Benchmark.realtime { work('data_large.txt') }} с."
end

work_with_benchmark
