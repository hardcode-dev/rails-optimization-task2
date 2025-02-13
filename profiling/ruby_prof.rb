# frozen_string_literal: true

require 'ruby-prof'
require_relative '..//task-2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS # что-то плохо работает

result = RubyProf.profile do
  work(file_name: 'data_50_thousands_lines.txt', disable_gc: true)
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('profiling/graph.html', 'w+'))


