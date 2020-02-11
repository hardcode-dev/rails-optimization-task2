require 'benchmark'
require_relative 'task-2.rb'

puts "Start"

time = Benchmark.realtime do
  work('data500000.txt', disable_gc: false)
end

puts "Finish in #{time.round(2)}"
