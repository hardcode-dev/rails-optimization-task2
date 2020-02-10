# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

# require_relative 'task-1.rb'
require_relative 'flow-task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data_large.txt')
end

report.pretty_print(scale_bytes: true)

# puts ""
# puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
