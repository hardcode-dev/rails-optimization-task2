require 'memory_profiler'
require_relative '../task-2.rb'

report = MemoryProfiler.report do
 work(file_path: 'test_data/data5000.txt')
end

report.pretty_print
