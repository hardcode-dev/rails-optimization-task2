# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

require 'ruby-prof'
require_relative 'task-2.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work('data_100000.txt', disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/callstack.html', 'w+'))
