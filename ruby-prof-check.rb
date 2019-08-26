require_relative 'task-2'
require 'benchmark'

time = Benchmark.realtime do
  work('data_large.txt')
end

puts "Time: #{time.inspect}"
