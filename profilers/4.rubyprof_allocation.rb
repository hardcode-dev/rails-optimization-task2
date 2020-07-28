require 'ruby-prof'
require_relative '../task/optimization'

puts 'Start'

RubyProf.measure_mode = RubyProf::ALLOCATIONS
# profile the code
result = RubyProf.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('reports/rubyprof_dot.dot'), 'w+')

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('reports/graph.html'), 'w+')

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/callstack.html'), 'w+')

puts 'Finish'
