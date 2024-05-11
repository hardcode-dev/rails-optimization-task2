require_relative '../task-2'

require 'ruby-prof'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  GC.disable
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('tmp/ruby_prof/flat.txt', 'w+'))

# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('tmp/ruby_prof/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('tmp/ruby_prof/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('tmp/ruby_prof/callstack.html', 'w+'))
