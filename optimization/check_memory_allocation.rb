require 'benchmark'

require_relative '../work.rb'

time = Benchmark.realtime do
  work(filename: 'data_test.txt', disable_gc: false)
end

# GC.start(full_mark: true, immediate_sweep: true)

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

puts "Finished in #{time.round(2)}"
