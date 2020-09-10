# frozen_string_literal: true

require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  work('tmp/data_80000.txt', disable_gc: false)
end
report.pretty_print(scale_bytes: true)
