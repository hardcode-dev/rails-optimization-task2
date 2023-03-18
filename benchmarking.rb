require 'benchmark'
require_relative 'task-2'

# 100_000 - 117.41s
# MEMORY USAGE: 571 MB

time = Benchmark.realtime do |x|
  work('data/data_100k.txt')
end
puts "Finish in #{time.round(2)}"

# 100_000 - ?
