require_relative 'task-2'
require 'ruby-prof'

GC.disable
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  Work.new.work('data_part_1000000.txt')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

GC.enable