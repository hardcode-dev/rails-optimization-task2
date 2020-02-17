require 'task-2.rb'
require 'memory_profiler'
require 'ruby-prof'

# MemoryProfiler

report = MemoryProfiler.report do
  work('data_500000.txt')
end
report.pretty_print(scale_bytes: true)


# RubyProf

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work('data_50000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))