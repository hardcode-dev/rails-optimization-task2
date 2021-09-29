require 'benchmark'
require 'memory_profiler'

require_relative '../work.rb'

report = MemoryProfiler.report do
  work(filename: 'data_test.txt', disable_gc: false)
end

report.pretty_print(scale_bytes: true)
