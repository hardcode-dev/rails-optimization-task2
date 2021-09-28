#ruby optimization_tools/memory_profiler.rb

require_relative '../task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work
end
report.pretty_print(scale_bytes: true)