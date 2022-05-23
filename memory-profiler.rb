# require 'benchmark'
require 'memory_profiler'
require_relative './task-2'

report = MemoryProfiler.report do
  work(file_name: 'fixtures/data_large.txt', disable_gc: true)
end
report.pretty_print(scale_bytes: true)
