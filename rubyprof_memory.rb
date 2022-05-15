require 'ruby-prof'
require_relative 'task-2.rb'

filename = "data/data_#{ENV['LINES']}.txt"

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(filename)
end

# How to read:
# brew install qcachegrind
# qcachegrind ruby_prof_reports/<file>
printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
