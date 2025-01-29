# frozen_string_literal: true

require 'ruby-prof'
require 'stringio'
require_relative '../task-2.rb'

RubyProf.measure_mode = RubyProf::MEMORY

`head -n 2500000 data_large.txt > data_large12500.txt`

GC.disable

result = RubyProf.profile do
  work(filename: 'data_large12500.txt')
end

RubyProf::FlatPrinter.new(result).print(File.open('reports/rubyprof_flat.txt', 'w+'))
RubyProf::GraphHtmlPrinter.new(result).print(File.open('reports/rubyprof_graph.html', 'w+'))
RubyProf::CallStackPrinter.new(result).print(File.open('reports/rubyprof_callstack.html', 'w+'))
RubyProf::CallTreePrinter.new(result).print(path: 'reports', profile: 'callgrind')

GC.enable

`rm data_large12500.txt`
