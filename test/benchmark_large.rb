require 'benchmark'
require_relative './../task-2'

file_path = "#{__dir__}/../tmp/data_large.txt"

Benchmark.bmbm do |x|
  x.report('real:') do
    work(file_path)
  end
end
