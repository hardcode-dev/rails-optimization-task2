# frozen_string_literal: true

require 'benchmark/ips'
require 'benchmark/memory'
require_relative '../task-2'

'./datasets/data_large.txt'
# filename = './datasets/data10_000.txt'

# Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)
#
#   x.report("work") { work(filename) }
# end

# ruby 3.2.4 (2024-04-23 revision af471c0e01) [arm64-darwin23]
# Warming up --------------------------------------
# work     1.000 i/100ms
# Calculating -------------------------------------
# work      0.111 (± 0.0%) i/s -      1.000 in   9.011541s
# with 99.0% confidence

# > ruby task-2.rb
# MEMORY USAGE: 40 MB
