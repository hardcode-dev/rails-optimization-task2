# frozen_string_literal: true

require 'ruby-prof'
require 'stackprof'
require 'json'
require_relative 'task-2'

work('data_large.txt')

# Actual feed-back loop profile step
# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#  work('data_sample_10_000.txt', gc_disable: true)
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'optimization_reports', profile: 'profile')

# RubyProf Memory Allocations
# RubyProf.measure_mode = RubyProf::ALLOCATIONS
#
# result = RubyProf.profile do
#  work('data_sample_50_000.txt', gc_disable: true)
# end
#
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('optimization_reports/flat.txt', 'w+'))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('optimization_reports/graph.html', 'w+'))
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('optimization_reports/callstack.html', 'w+'))

# StackProf memory allocations
# StackProf.run(mode: :object, out: 'optimization_reports/stackprof.dump', raw: true) do
#  work('data_sample_50_000.txt', gc_disable: true)
# end

## StackProf flamegraph memory allocations
# profile = StackProf.run(mode: :object, raw: true) do
#  work('data_sample_50_000.txt', gc_disable: true)
# end
#
# File.write('optimization_reports/stackprof.json', JSON.generate(profile))

# RubyProf callgrind memory
# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#  work('data_sample_50_000.txt', gc_disable: true)
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'optimization_reports', profile: 'profile')
