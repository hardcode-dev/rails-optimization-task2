require 'memory_profiler'
require_relative 'task-2.rb'

def print_memory_usage
  "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

puts 'start'
puts "RAM for process at the start of process - #{print_memory_usage}"

report = MemoryProfiler.report do
  Report.new.work(filename: 'data_large_100000.txt')
end

puts "RAM for process at the end of process - #{print_memory_usage}"

report.pretty_print(scale_bytes: true)
