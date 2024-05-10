#!/usr/bin/env ruby

require_relative 'task-2'
require 'memory_profiler'

report = MemoryProfiler.report do
  work(File.join(__dir__, ARGV.first))
end
report.pretty_print(scale_bytes: true)
