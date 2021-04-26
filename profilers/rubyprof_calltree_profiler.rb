require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

RubyProf.start

work(ENV['FILENAME'] || 'data.txt')

result = RubyProf.stop

printer = RubyProf::CallTreePrinter.new(result)

printer.print(path: './reports', profile: 'callgrind')
