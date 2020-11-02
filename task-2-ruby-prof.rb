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
# SOURCE_FILE = 'data_500000.txt'
# SOURCE_FILE = 'data_large.txt'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  FastReportBuilder.new.call(SOURCE_FILE, 'fast_report.json')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))


