# frozen_string_literal: true

require 'memory_profiler'
require_relative './task-2'

report = MemoryProfiler.report do
  work(ENV['DATA_FILE'] || 'data.txt')
end

report.pretty_print(scale_bytes: true)
