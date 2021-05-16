# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

require 'ruby-prof'
require_relative '../parser'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  Parser.new(disable_gc: false).work('data/data500_000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/callstack.html', 'w+'))
