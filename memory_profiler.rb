require 'memory_profiler'
require_relative 'work'


report = MemoryProfiler.report do
  work("data/data#{ENV['SIZE']}.txt", disable_gc: ENV['GB'] || true)
end
report.pretty_print(scale_bytes: true)
