require 'benchmark'
require_relative 'task-2'

puts "Start"

time = Benchmark.realtime do
  work(file_name: 'data_large.txt')
end

puts "Finish in #{time.round(2)} seconds"
