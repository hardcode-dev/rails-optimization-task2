require 'memory_profiler'
require_relative 'task-2-improved'

report = MemoryProfiler.report do
  ReportGenerator.new(input: 'data100000.txt', output: 'result100000.json').work;
end

report.pretty_print(scale_bytes: true)