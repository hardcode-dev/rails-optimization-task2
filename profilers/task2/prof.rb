# dot -Tpng graphviz.dot > graphviz.png

require_relative 'helper'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  Optimization::TaskTwo.work("#{@root}data/dataN.txt", false)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("ruby_prof_reports/task2/flat_#{Time.now.to_i}.txt", 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open("ruby_prof_reports/task2/graphviz_#{Time.now.to_i}.dot", 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("ruby_prof_reports/task2/graph_#{Time.now.to_i}.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("ruby_prof_reports/task2/callstack_#{Time.now.to_i}.html", 'w+'))
