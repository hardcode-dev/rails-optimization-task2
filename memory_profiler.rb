require 'memory_profiler'
require_relative 'task-2.rb'

report = MemoryProfiler.report do
  work('files/data_100_000.txt')
end

report.pretty_print(scale_bytes: true)
