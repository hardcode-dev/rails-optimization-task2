require 'memory_profiler'
require_relative 'task-2.rb'

filename = "data/data_#{ENV['LINES']}.txt"

report = MemoryProfiler.report do
  work(filename)
end
report.pretty_print(scale_bytes: true)
