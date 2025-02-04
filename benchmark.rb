require_relative 'work'
require 'benchmark'

puts Benchmark.realtime { work('data/data20000.txt', disable_gc: true) }
