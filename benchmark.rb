require 'benchmark'
require_relative './task-2'

time = Benchmark.realtime do |x|
  work(file_name: 'fixtures/data_large.txt', disable_gc: false)
end

puts time