require 'memory_profiler'
require_relative '../../task-2'

report = MemoryProfiler.report do
  GC.disable
  work('../../data-500.txt')
end

File.write('reports/memory_profiler.txt', report.pretty_print)
