require_relative '../../task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(file: 'data/data_32_500.txt', disable_gc: false)
end
report.pretty_print(scale_bytes: true)
