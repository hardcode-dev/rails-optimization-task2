# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

report = Report.new('data/data_512x.txt')

result = RubyProf.profile do
  report.work
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'ruby_prof_reports', profile: 'profile')
