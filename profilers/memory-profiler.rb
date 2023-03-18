# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require_relative '../task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data/data_large.txt')
end

report.pretty_print(to_file: 'reports', scale_bytes: true, normalize_paths: true)
