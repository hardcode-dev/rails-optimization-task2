# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task_2'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('instruments/ruby_prof_reports/callstack.html', 'w+'))
