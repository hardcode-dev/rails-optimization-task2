# frozen_string_literal: true

# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

require 'ruby-prof'
require_relative '../../task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  ParseFile.new(data_file_path: 'data/data_5000.txt').work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('reports/ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/ruby_prof_reports/callstack.html', 'w+'))
