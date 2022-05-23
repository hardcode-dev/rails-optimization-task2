require 'memory_profiler'
require_relative 'task-2'

report = MemoryProfiler.report do
  work(file_name: ENV['FILE_NAME'], gc_disabled: false)
end
report.pretty_print(scale_bytes: true)