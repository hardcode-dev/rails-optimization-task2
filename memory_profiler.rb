require_relative 'task-2'

require 'memory_profiler'

report = MemoryProfiler.report do
  work('tmp/data_large.txt')
end
report.pretty_print(scale_bytes: true)
