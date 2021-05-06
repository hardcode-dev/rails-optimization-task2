# frozen_string_literal: true

require_relative 'task-2'
require 'benchmark'

time = Benchmark.realtime do
  work('data_large.txt')
end
puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
puts "Finish in #{time.round(2)}"
