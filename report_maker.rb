# TMPfrozen_string_literal: true
require_relative 'task-2'
require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
data_size = 50000

#GC.disable
#report = MemoryProfiler.report do 
#    work("data/data#{data_size}.txt")
#end

#report.pretty_print(color_output: true, scale_bytes: true, to_file: "outputs/memory_profiler_#{Time.now.to_i}.txt")
#StackProf.run(mode: :object, out: 'outputs/stackprof.dump', raw: true) do
#    work("data/data#{data_size}.txt")
#end

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do 
    work("data/data#{data_size}.txt")
end

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('outputs/graph.html', 'w+'))

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('outputs/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('outputs/graphviz.dot', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('outputs/callstack.html', 'w+'))

open('outputs/graph.html')

#RubyProf.measure_mode = RubyProf::MEMORY
#result = RubyProf.profile do
#    work("data/data#{data_size}.txt")
#end
#printer = RubyProf::CallTreePrinter.new(result)
#printer.print(path: 'outputs', profile: 'profile')

