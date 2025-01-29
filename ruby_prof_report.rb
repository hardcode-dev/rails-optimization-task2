require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  Report.new.call('data_small.txt', true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
