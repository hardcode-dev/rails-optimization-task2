require_relative '../../task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(
    file: ENV.fetch('DATA_FILE', "data/data_32_500.txt"),
    disable_gc: false
  )
end

report.pretty_print(scale_bytes: true, color_output: true)
report.pretty_print(scale_bytes: true, to_file: 'reports/tmp/memory-profiler/result.txt')