require 'memory_profiler'
require_relative 'work'


report = MemoryProfiler.report do
  work('data/data20000.txt', disable_gc: true)
end
report.pretty_print(scale_bytes: true)
