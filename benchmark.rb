require_relative 'task-2'
require 'benchmark'

puts Benchmark.realtime { work("spec/fixtures/files/data_20000.txt", disable_gc: true) }