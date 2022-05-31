require "benchmark"
require_relative 'parser'

time = Benchmark.realtime do
  Parser.new.work(file_name: "data_large.txt")
end

puts "finish in #{time.round(2)}"
