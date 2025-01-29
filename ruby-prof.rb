# RubyProf Flat report
# ruby 12-ruby-prof-flat.rb
# cat ruby_prof_reports/flat.txt
require 'ruby-prof'
require_relative 'task-2-with-argument.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS
`head -n #{8000} data_large.txt > data_small.txt`

result = RubyProf.profile do
  work("data_small.txt")
end

flat_printer = RubyProf::FlatPrinter.new(result)
flat_printer.print(File.open("ruby_prof_reports/flat.txt", "w+"))

dot_printer = RubyProf::DotPrinter.new(result)
dot_printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

graph_printer = RubyProf::GraphHtmlPrinter.new(result)
graph_printer.print(File.open("ruby_prof_reports/graph.html", "w+"))

printer_callstack = RubyProf::CallStackPrinter.new(result)
printer_callstack.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
