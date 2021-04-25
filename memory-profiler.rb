# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require_relative 'task-2'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('samples/10000.txt')
end
report.pretty_print(scale_bytes: true)
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

