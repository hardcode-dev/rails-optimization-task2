require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  work('./spec/fixtures/data_5000.txt')
end

report.pretty_print
