# frozen_string_literal: true

require 'memory_profiler'
require_relative '../task-2.rb'

`head -n 2500000 data_large.txt > data_small.txt`

GC.disable
report = MemoryProfiler.report do
  work(filename: 'data_small.txt', gc: false)
end
GC.enable

report.pretty_print(scale_bytes: true)

`rm data_small.txt`
