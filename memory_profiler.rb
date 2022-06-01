require_relative 'parser'
require 'benchmark'
require 'memory_profiler'

report = MemoryProfiler.report do
  Parser.new.work(file_name: 'data20000.txt')
end

report.pretty_print(scale_bytes: true)
