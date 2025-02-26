require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf::Profile.profile do
  work("spec/fixtures/files/data_20000.txt", disable_gc: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat_memory.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph_memory.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack_memory.html', 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')