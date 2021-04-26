require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

RubyProf.start

work(ENV['FILENAME'] || 'data.txt')

result = RubyProf.stop

printer = RubyProf::FlatPrinter.new(result)

printer.print(STDOUT)
