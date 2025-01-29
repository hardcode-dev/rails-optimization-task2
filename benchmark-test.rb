require 'benchmark'
require_relative 'task-2-improved'

time = Benchmark.realtime do
  ReportGenerator.new(input: 'data_large.txt', output: 'result_benchmark.json').work
end

puts "Finish in #{time.round(2)}"