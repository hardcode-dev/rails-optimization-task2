require 'ruby-prof'
require_relative '../../task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  GC.disable
  work('../../data_large.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("flat-100000.txt", "w+"))