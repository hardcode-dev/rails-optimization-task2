# frozen_string_literal: true

require 'ruby-prof'
require_relative '../task-2'

RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work('benchmarks/demo_data/demo_data_10000.txt')
end

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: 'benchmarks/reports/ruby_prof/', profile: 'profile')
