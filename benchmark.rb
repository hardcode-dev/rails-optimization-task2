require 'benchmark'
require_relative 'task-2'

time = Benchmark.realtime do
  work(file: 'data_large.txt')
end

puts "Finish in #{time.round(2)}"