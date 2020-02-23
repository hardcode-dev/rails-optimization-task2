require_relative '../lib/task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(data_path('data_100000.txt'), disable_gc: true)
end
report.pretty_print(scale_bytes: true)
