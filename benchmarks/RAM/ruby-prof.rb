require 'ruby-prof'
require_relative '../../task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  GC.disable
  work('../../data-500.txt')
end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open("reports/flat.txt", "w+"))

# printer = RubyProf::GraphPrinter.new(result)
# printer.print(STDOUT, :min_percent => 2)
#
# printer = RubyProf::MultiPrinter.new(result)

printer = RubyProf::CallTreePrinter(result) #dont work  undefined method `CallTreePrinter' for RubyProf:Module

printer.print(:path => ".", :profile => "profile")
