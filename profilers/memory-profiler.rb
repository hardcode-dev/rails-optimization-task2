# memory_profiler (ruby 2.3.8+)
# allocated - total memory allocated during profiler run
# retained - survived after MemoryProfiler finished

require 'benchmark'
require 'memory_profiler'
require_relative '../parser'

report = MemoryProfiler.report do
  Parser.new(disable_gc: false).work('data/data500_000.txt')
end
report.pretty_print(scale_bytes: true)
