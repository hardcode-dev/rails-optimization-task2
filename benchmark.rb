require 'benchmark'
require_relative 'task-2_with_file.rb'

time = Benchmark.realtime do
  work('data_large.txt')
end
puts "Finish in #{time.round(2)}"