require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('spec/fixtures/files/data_40000.txt', disable_gc: true)
end
report.pretty_print(scale_bytes: true)
