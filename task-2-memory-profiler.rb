# head -n <N lines> data_large.txt > data_prof.txt
# ruby task-2-memory-profiler.rb

require 'memory_profiler'
require_relative 'task-2'

report = MemoryProfiler.report do
  work(file_name: 'data_prof.txt')
end
report.pretty_print(scale_bytes: true, to_file: 'memory_profiler/report_step3.txt')
