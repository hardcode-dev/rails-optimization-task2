require_relative '../lib/task-2'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(data_path('data_100000.txt'))
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'test/ruby_prof_reports', profile: 'profile')
