require_relative 'task-2'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data_50_000.txt')
end

report.pretty_print(scale_bytes: true)