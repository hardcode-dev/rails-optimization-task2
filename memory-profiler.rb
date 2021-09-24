# frozen_string_literal: true

require_relative 'task-2.rb'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data_12000.txt')
end
report.pretty_print(scale_bytes: true)
