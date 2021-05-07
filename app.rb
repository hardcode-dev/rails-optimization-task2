# frozen_string_literal: true

require_relative 'task-2'
require 'benchmark'
# require 'memory_profiler'
# require 'stackprof'
# require 'ruby-prof'

time = Benchmark.realtime do
  work('data_large.txt')
end

# report = MemoryProfiler.report do
#   work('data10000.txt')
# end
# report.pretty_print(scale_bytes: true)


# StackProf.run(mode: :object, out: 'stackprof.dump', raw: true) do
#   work('data10000.txt')
# end

# RubyProf.measure_mode = RubyProf::ALLOCATIONS
# result = RubyProf.profile do
#   work('data10000.txt')
# end
#
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))
#
# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#   work('data_small.txt', disable_gc: false)
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'ruby_prof_reports', profile: 'profile')

puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
puts "Finish in #{time.round(2)}"
