require_relative '../task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work
end
report.pretty_print(scale_bytes: true)
