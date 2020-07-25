require_relative '../lib/task-2'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('files/data16000.txt')
end

report.pretty_print(scale_bytes: true)
