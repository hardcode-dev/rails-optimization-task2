require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('data30000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: './', profile: 'profile')
