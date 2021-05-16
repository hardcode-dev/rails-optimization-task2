require 'benchmark'
require_relative 'parser'

Benchmark.bmbm do |x|
  x.report('LARGE') { Parser.new.work('data/data_large.txt') }
end
