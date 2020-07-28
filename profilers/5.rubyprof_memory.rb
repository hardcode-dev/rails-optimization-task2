require 'ruby-prof'
require_relative '../task/optimization'

puts 'Start'

RubyProf.measure_mode = RubyProf::MEMORY
# profile the code
result = RubyProf.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'profile')

puts 'Finish'
