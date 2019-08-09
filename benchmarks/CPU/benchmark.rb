require 'benchmark'

require_relative '../../task-2'

time = Benchmark.realtime do |x|
  work('../../data_large.txt')
end

puts "Finish in #{time}"