require 'memory_profiler'
require_relative '../task-2.rb'

file_path = "#{__dir__}/../data/data1.txt"
report_path = "#{__dir__}/../tmp/memory_profiler.txt"

report = MemoryProfiler.report do
  work(file_path)
end

report.pretty_print(scale_bytes: true, to_file: report_path)
