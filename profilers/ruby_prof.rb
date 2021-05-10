# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

require 'ruby-prof'
require_relative '../src/report'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

GC.disable
result = RubyProf.profile do
  work('../data_64000.txt')
end
GC.enable

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('../reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('../reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('../reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('../reports/callstack.html', 'w+'))
