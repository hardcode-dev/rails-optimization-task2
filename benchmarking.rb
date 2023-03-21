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

# 2.
# MEMORY USAGE: 65 MB
# Finish in 0.39

# 3.
# MEMORY USAGE: 53 MB
# Finish in 0.25

# 3.
# MEMORY USAGE: 53 MB
# Finish in 0.25

# 4.
# MEMORY USAGE: 51 MB
# Finish in 0.1

# 5.
# MEMORY USAGE: 29 MB
# Finish in 0.2

# 100_000
# END
# MEMORY USAGE: 30 MB
# Finish in 0.5

time = Benchmark.realtime do |x|
  work('data/data_large.txt')
end
puts "Finish in #{time.round(2)}"
