require 'ruby-prof'
require_relative 'task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(file_name: ENV['FILE_NAME'], gc_disabled: true)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_memory_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_memory_reports/graphiz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_memory_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_memory_reports/callstack.html', 'w+'))