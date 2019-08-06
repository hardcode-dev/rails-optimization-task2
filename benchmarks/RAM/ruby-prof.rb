require 'ruby-prof'
require_relative '../../task-2'

RubyProf.measure_mode = RubyProf::MEMORY
# RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work('../../data-500.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat-500.txt', 'w+'))
#
# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('reports/graphviz.dot', 'w+'))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('reports/graph.html', 'w+'))

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/profile.graph.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'profile')