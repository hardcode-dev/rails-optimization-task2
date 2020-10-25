# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'benchmark'

require 'benchmark'
require 'memory_profiler'

# require_relative 'unit-test'

require_relative 'user'
require_relative 'slow_report_builder'
require_relative 'fast_report_builder'

# SlowReportBuilder.new.call('data_600.txt', 'slow_report.json')

SOURCE_FILE = 'data_120000.txt'

if ENV['MEM_PROF'] == '1'
  puts "👮🏻 Run with memory profiler."

  report = MemoryProfiler.report do
    FastReportBuilder.new.call(SOURCE_FILE, 'fast_report.json')
  end

  report.pretty_print(scale_bytes: true)

else
  # Just run and measure time.
  require_relative 'unit-test'

  time = Benchmark.realtime do
    FastReportBuilder.new.call(SOURCE_FILE, 'fast_report.json')
  end
  puts
  puts "Report finished in #{time.round(3)} seconds"
end
