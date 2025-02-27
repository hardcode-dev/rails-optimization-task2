require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf::Profile.profile do
  work("spec/fixtures/files/data_40000.txt", disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat_allocations.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph_allocations.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack_allocations.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
