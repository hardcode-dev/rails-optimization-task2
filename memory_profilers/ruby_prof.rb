# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

report = Report.new('data/data_512x.txt')

result = RubyProf.profile do
  report.work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

