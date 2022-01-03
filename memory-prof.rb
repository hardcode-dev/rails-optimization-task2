require 'ruby-prof'
require_relative 'task-2.rb'
require 'memory_profiler'

report = MemoryProfiler.report do
  work('data100000.txt')
end
report.pretty_print(scale_bytes: true)