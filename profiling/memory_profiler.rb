require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  Parser.new.work('../100000.txt')
end

report.pretty_print(color_output: true, scale_bytes: true)

