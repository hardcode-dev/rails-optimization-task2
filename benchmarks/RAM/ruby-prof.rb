require 'ruby-prof'
require_relative '../../task-1'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  GC.disable
  work('../../benchmarks/data-500.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("flat-500.txt", "w+"))