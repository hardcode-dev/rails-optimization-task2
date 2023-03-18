# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_2'

# На этот раз профилируем не allocations, а объём памяти!
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('data80000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'profile')

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/callstack.html', 'w+'))
