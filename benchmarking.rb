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

# 40_000
#
# File.foreach
# MEMORY USAGE: 316 MB
# Finish in 15.67

# 1.
# MEMORY USAGE: 179 MB
# Finish in 16.95

time = Benchmark.realtime do |x|
  work('data/data_40k.txt')
end
puts "Finish in #{time.round(2)}"
