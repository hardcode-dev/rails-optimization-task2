require_relative 'task-2'
require 'memory_profiler'

report = MemoryProfiler.report do
  Work.new.work('data_part_1000000.txt')
end

report.pretty_print(scale_bytes: true)
