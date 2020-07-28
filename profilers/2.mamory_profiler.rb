require 'benchmark'
require 'memory_profiler'
require_relative '../task/optimization'

puts 'Start'

report = MemoryProfiler.report do
  work
end

report.pretty_print(scale_bytes: true)
