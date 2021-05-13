require 'benchmark'
require_relative 'src/report'

LINES_COUNTS = [1000, 2000, 4000, 8000, 16_000].freeze

Benchmark.bmbm do |x|
  # LINES_COUNTS.each do |lines|
  #   x.report("Lines: #{lines}") { work('data_16000.txt', lines, false) }
  # end
  # LINES_COUNTS.each do |lines|
  #   x.report("Lines: #{lines}") { work('data_large.txt', lines, true) }
  # end
  # x.report("Lines: #{64_000}") { work('data_64000.txt', nil, true) }
  # x.report("Lines: 500_000") { work('data_500000.txt', nil, false) }
  x.report("Data large") { work('data_large.txt', nil, false) }
end

puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
