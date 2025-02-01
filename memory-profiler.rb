# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require 'benchmark'
require 'memory_profiler'
require_relative 'task-2-with-argument.rb'

`head -n #{8000} data_large.txt > data_small.txt`

report = MemoryProfiler.report do
  work('data_small.txt')
end
report.pretty_print(scale_bytes: true)
