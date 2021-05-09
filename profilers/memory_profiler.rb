require 'benchmark'
require 'memory_profiler'
require_relative '../src/report'

report = MemoryProfiler.report do
  work('../data_16000.txt')
end
report.pretty_print(scale_bytes: true)
