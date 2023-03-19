require 'benchmark'
require_relative 'task-2'

# 100_000
#
# Start
# MEMORY USAGE: 634 MB
# Finish in 125.11s

# File.foreach
# MEMORY USAGE: 596 MB
# Finish in 119.95

time = Benchmark.realtime do |x|
  work('data/data_100k.txt')
end
puts "Finish in #{time.round(2)}"
