require 'benchmark'
require_relative '../task-2'

Benchmark.bm do |x|
  x.report('processing_time') { work('data/data_4000.txt') }
end
