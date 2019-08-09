require_relative '../task-2'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  Parser.new.work('../100000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("profiling/flat.txt", 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("profiling/graph.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("profiling/stack.html", 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'profiling/', profile: 'profile')
