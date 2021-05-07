require_relative 'task-2'
require 'memory_profiler'

print_memory_usage do
  print_time_spent do
    report = MemoryProfiler.report do
      # work(file: 'data10000.txt', disable_gc: false)
      work(file: 'data100000.txt', disable_gc: true)
      # work(file: 'data_large.txt', disable_gc: false)
    end

    report.pretty_print(scale_bytes: true)
  end
end
