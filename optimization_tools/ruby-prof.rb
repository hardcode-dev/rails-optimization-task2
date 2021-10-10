#ruby optimization_tools/ruby-prof.rb

require 'ruby-prof'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  GC.disable
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('optimization_tools/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('optimization_tools/ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('optimization_tools/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('optimization_tools/ruby_prof_reports/callstack.html', 'w+'))