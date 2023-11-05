require 'benchmark'
require_relative 'task-2'

puts 'Started'
time = Benchmark.realtime do
  work('data10000.txt')
end
puts "Finished in #{time.round(2)}"

# Iteration 0: measurement without any changes for 10000 first strings = 0.73 seconds
# Iteration 1: measurement after streaming refactoring = 0.06 seconds
