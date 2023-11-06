require 'memory_profiler'
require_relative 'task-2'

report = MemoryProfiler.report do
  # work('data10000.txt')
  work('data_large.txt')
end
report.pretty_print(scale_bytes: true)
