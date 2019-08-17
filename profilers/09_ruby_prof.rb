# ruby profilers/09_ruby_prof.rb
# dot -Tpng profilers/ruby_prof_reports/graphviz.dot > graphviz.png
# open profilers/ruby_prof_reports/graph.html

require_relative '../config/environment'
require 'ruby-prof'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

GC.disable

result = RubyProf.profile do
  Task.new(data_file_path: './spec/fixtures/data_100k.txt').work
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/flat.txt', 'w+'))

printer = RubyProf::DotPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/graphviz.dot', 'w+'))

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('profilers/ruby_prof_reports/callstack.html', 'w+'))
