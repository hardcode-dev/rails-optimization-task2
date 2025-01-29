# frozen_string_literal: true

require 'ruby-prof'
require './task-2'

# RubyProf.measure_mode = RubyProf::MEMORY
RubyProf.measure_mode = RubyProf::WALL_TIME
# RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile(track_allocations: true) do
  App.new('data_large_16x.txt').work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'ruby_prof_reports', profile: 'profile')

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
