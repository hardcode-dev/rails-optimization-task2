# frozen_string_literal: true

# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require_relative '../task-1'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data/data_10000.txt')
end
report.pretty_print(scale_bytes: true)
