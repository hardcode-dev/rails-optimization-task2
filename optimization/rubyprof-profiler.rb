require 'ruby-prof'

require_relative '../work.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS
# RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(filename: 'data_test.txt', disable_gc: true)
end

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open("reports/callstack-#{Time.now.to_s.split(' ')[1]}.html", "w+"))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'reports', profile: 'profile')
