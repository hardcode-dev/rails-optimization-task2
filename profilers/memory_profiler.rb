# frozen_string_literal: true

require_relative '../task_2'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  work
end
report.pretty_print(scale_bytes: true)
