# frozen_string_literal: true

require 'benchmark'

require_relative '../task-2'

def run(dataset_size: 100_000)
  dataset_size = ARGV[0].to_i if ARGV[0]
  puts ARGV[0]
  `head -n #{dataset_size} data_large.txt > data.txt`
  puts "TIME: #{Benchmark.realtime { work }}"
end
run
