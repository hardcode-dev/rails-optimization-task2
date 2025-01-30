# frozen_string_literal: true

require_relative 'task-2'
require 'benchmark'

puts format('INITIAL MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))

monitor_thread = Thread.new do
  while true
    puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
    sleep(0.1)
  end
end

work('data/data20000.txt')
monitor_thread.kill

# puts Benchmark.measure { work('data/data20000.txt') }
