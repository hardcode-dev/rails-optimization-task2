# frozen_string_literal: true

require 'ruby-prof'
require_relative 'task_2'

RubyProf.measure_mode = RubyProf::WALL_TIME

GC.disable
result = RubyProf.profile do
  work('data_100000.txt')
end
GC.enable

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))