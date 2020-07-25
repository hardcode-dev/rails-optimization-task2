# frozen_string_literal: true

require_relative 'task-2'

require 'benchmark'
time = Benchmark.realtime do
  work(ENV.fetch('DATA_FILE', 'tmp/data_large.txt'))
end

puts "data_large Finish in #{time.round(2)}"
puts "MEMORY USAGE: #{`ps -o rss= -p #{Process.pid}`.to_i / 1024} MB"
