# require_relative 'task-2.rb'
#
# # work('data_100k_rows.txt')
# work('data_large.txt')

require 'ruby-prof'
require_relative 'task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('data_large.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')