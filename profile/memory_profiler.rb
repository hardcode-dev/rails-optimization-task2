require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  work('data/data_100000.txt')
end

report.pretty_print
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
