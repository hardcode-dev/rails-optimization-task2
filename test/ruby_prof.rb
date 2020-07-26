require 'ruby-prof'
require 'stringio'
require_relative '../task-2.rb'

file_path = "#{__dir__}/../data/data.txt"

GC.disable

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(file_path)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/ALLOCATIONS-ruby-prof-flat.txt", 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/ALLOCATIONS-ruby-prof-graph.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/ALLOCATIONS-ruby-prof-callstack.html", 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: "#{__dir__}/../tmp/", profile: 'callgrind')

#
RubyProf.measure_mode = RubyProf::MEMORY

result = RubyProf.profile do
  work(file_path)
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/MEMORY-ruby-prof-flat.txt", 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/MEMORY-ruby-prof-graph.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open("#{__dir__}/../tmp/MEMORY-ruby-prof-callstack.html", 'w+'))

printer = RubyProf::CallTreePrinter.new(result)
printer.print(path: "#{__dir__}/../tmp/", profile: 'callgrind')

