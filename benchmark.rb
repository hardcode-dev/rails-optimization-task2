require_relative 'work'
require 'benchmark'

puts "SIZE  #{ENV['SIZE']}"
puts Benchmark.realtime { work("data/data#{ENV['SIZE']}.txt", disable_gc: ENV['GB'] || true) }
