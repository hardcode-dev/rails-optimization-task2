# frozen_string_literal: true

require_relative '../../task-2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  ParseFile.new(data_file_path: 'data/data_10000.txt').work
end
report.pretty_print(scale_bytes: true)
