# frozen_string_literal: true

require 'memory_profiler'
require_relative '../task-2.rb'

`head -n 12500 data_large.txt > data_small.txt`

report = MemoryProfiler.report do
  work(filename: 'data_small.txt', gc: false)
end

report.pretty_print

`rm data_small.txt`
