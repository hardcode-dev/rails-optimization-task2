require 'benchmark'
require 'memory_profiler'
require_relative '../src/report'

GC.disable
report = MemoryProfiler.report do
  work('../data_16000.txt')
end
GC.enable

report.pretty_print(scale_bytes: true)
