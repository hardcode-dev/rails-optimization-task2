# ruby-prof
# dot -Tpng graphviz.dot > graphviz.png

# require 'ruby-prof'
# require_relative '../spec/spec_helper'
# require 'stackprof'

require_relative 'setup'
# RubyProf.measure_mode = RubyProf::WALL_TIME

# result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }
# printer = RubyProf::FlatPrinter.new(result)
# file_path = File.join(Setup::REPORTS_PATH, 'flat.txt')
# file = File.open(file_path, "w+")
# printer.print(file)

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile { work(Setup::FILE_PATH, disable_gc: true) }

printer = RubyProf::FlatPrinter.new(result)
file_path = File.join(Setup::REPORTS_PATH, 'flat.txt')
file = File.open(file_path, 'w+')
printer.print(file)

# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('profiling/ruby_prof_reports/graphviz.dot', 'w+'))

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('profiling/ruby_prof_reports/graph.html', 'w+'))

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('profiling/ruby_prof_reports/callstack.html', 'w+'))
