require 'ruby-prof'
require 'memory_profiler'
require_relative '../task-2'

report = MemoryProfiler.report do
  work(ENV['FILENAME'] || 'data.txt')
end

puts report.pretty_print(scaly_bytes: true)
