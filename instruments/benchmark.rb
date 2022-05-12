# frozen_string_literal: true

require_relative '../task-2'
require 'benchmark'

puts "Start"
time = Benchmark.realtime do
  work
end

puts "Finish in #{time} seconds"
