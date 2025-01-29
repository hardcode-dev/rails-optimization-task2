require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  Report.new.call('data100000.txt')
end
report.pretty_print(scale_bytes: true)