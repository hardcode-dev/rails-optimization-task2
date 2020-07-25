require_relative '../lib/task-2'
require 'benchmark'

time = Benchmark.measure do
  work('data_large.txt')
end

puts time
