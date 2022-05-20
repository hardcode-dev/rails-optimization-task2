# frozen_string_literal: true

require 'memory_profiler'
require './task-2'

report = MemoryProfiler.report do
  App.new('data_large_64x.txt').work
end

report.pretty_print(scale_bytes: true)
