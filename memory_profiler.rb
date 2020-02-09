# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require_relative 'task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report { work('data_100_000.txt', disable_gc: false) }

report.pretty_print(scale_bytes: true)
