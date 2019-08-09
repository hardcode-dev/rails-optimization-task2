require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  Parser.new.work('../100000.txt')
end

report.pretty_print(color_output: false, scale_bytes: true, to_file: 'profiling/memory_profiler.txt')

