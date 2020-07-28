require 'benchmark'
require_relative '../task/optimization'

puts 'Start'

puts "MEMORY USAGE before start: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

time = Benchmark.realtime do
  work(benchmark: true)
end

puts 'ObjectSpace count objects: '
pp ObjectSpace.count_objects
puts GC.stat
puts "MEMORY USAGE after finish: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
puts "Finid in #{time}"
