require 'memory_profiler'
require_relative 'task-2'

report = MemoryProfiler.report do
  work('data_100.txt')
end
report.pretty_print(scale_bytes: true)
