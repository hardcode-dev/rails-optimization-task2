require 'ruby-prof'
require_relative 'task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

res = RubyProf.profile do
  work('data_100_000.txt')
end

printer = RubyProf::FlatPrinter.new(res)
printer.print(File.open("prof_reports/flat.txt", "w+"))

printer = RubyProf::DotPrinter.new(res)
printer.print(File.open("prof_reports/graphviz.dot", "w+"))

printer = RubyProf::GraphHtmlPrinter.new(res)
printer.print(File.open("prof_reports/graph.html", "w+"))

printer = RubyProf::CallStackPrinter.new(res)
printer.print(File.open("prof_reports/callstack.html", "w+"))

# printer = RubyProf::CallTreePrinter.new(res)
# printer.print(path: 'prof_reports', profile: true)