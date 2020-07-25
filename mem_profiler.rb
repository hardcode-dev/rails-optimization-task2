require 'memory_profiler'
require_relative 'task-2'

report = MemoryProfiler.report do
  work(file_path: 'data_samples/data1000.txt')
end

report.pretty_print(to_file: 'reports/mem_prof.txt')
