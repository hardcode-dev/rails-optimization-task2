require 'memory_profiler'
require_relative '../../task-2'

MemoryProfiler.report do
  work('../../data-500.txt')
end.pretty_print(to_file: 'reports/memory_profiler.txt', scale_bytes: true)
