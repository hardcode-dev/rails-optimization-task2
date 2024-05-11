require_relative '../task-2'

require 'memory_profiler'

report = MemoryProfiler.report do
  GC.disable
  work
end

report.pretty_print
