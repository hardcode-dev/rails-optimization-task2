# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

require 'ruby-prof'
require_relative '../../task-2.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(
    file: ENV.fetch('DATA_FILE', "data/data_32_500.txt"),
    disable_gc: false
  )
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('reports/tmp/ruby-prof/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/tmp/ruby-prof/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('reports/tmp/ruby-prof/callstack.html', 'w+'))
