require_relative 'task-2'

require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(filename: 'files/data_10_000.txt', disable_gc: false)
end
report.pretty_print(scale_bytes: true)
