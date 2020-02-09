require 'ruby-prof'
require_relative 'task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('data_40000.txt', disable_gc: true)
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
