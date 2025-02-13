# frozen_string_literal: true

require 'benchmark'
require 'memory_profiler'
#require_relative '../report_processor'
require_relative '../task-2'

report = MemoryProfiler.report do
  work(file_name: 'data_500_thousands_lines.txt', disable_gc: false)
end

report.pretty_print(scale_bytes: true)
