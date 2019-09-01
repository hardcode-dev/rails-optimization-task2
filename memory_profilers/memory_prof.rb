# frozen_string_literal: true

require_relative '../task-2.rb'
require 'benchmark'
require 'memory_profiler'

report = Report.new('data/data_512x.txt')

memory_report = MemoryProfiler.report do
  report.work
end

memory_report.pretty_print(scale_bytes: true)
