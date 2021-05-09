# TMPfrozen_string_literal: true
require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
data_size = 50000

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do 
    work("data/data#{data_size}.txt", true)
end


printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('outputs/graph.html', 'w+'))

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('outputs/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('outputs/graphviz.dot', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('outputs/callstack.html', 'w+'))

system('open outputs/graph.html')


 