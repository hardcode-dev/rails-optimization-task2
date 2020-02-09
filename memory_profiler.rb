require_relative 'task-2.rb'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data_40000.txt', disable_gc: true)
end
report.pretty_print(scale_bytes: true)
