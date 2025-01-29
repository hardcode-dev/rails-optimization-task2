# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require 'benchmark'
require 'memory_profiler'
require_relative 'task-2.rb'

report = MemoryProfiler.report do
  work('data100000.txt', disable_gc: false)
end
report.pretty_print(scale_bytes: true)
