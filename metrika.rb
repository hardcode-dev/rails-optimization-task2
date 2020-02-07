require 'benchmark'
require_relative 'task-2'

time = Benchmark.realtime do
  Report.new.call('data100000.txt')
end

puts "Finish in #{time.round(2)}"
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)