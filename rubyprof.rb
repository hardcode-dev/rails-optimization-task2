require 'ruby-prof'
require_relative 'task-2-improved'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  ReportGenerator.new(input: 'data100000.txt', output: 'result100000.json').work;
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_grapthviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_callstack.html', 'w+'))