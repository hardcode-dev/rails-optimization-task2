require_relative 'task-2'
require 'benchmark'

require 'benchmark/ips'

Benchmark.ips do |x|
  x.config(stats: :bootstrap, confidence: 95)

  x.report("ips") do
    work('samples/10000.txt')
  end
end
