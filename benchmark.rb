# frozen_string_literal: true

require_relative 'memory_reporter'
require_relative 'bench_wrapper'
require_relative 'task-2'

# path = "data/data#{ARGV[0] || 50000}.txt"
path = 'data_large.txt'
report_memory = ARGV[0] == '--report-memory'

if report_memory
  reporter = MemoryReporter.new

  reporter.start
  work(path)
else
  measure do
    work(path)
  end
end
