require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work('data/data_100000.txt')
end

# print a graph profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, {})

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profile/reports/callstack.html', 'w+'))
