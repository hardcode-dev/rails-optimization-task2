# frozen_string_literal: true

require 'benchmark'
require 'memory_profiler'
require_relative 'task_2'

GC.disable
report = MemoryProfiler.report do
  work('data_100000.txt')
end
GC.enable

report.pretty_print(scale_bytes: true)