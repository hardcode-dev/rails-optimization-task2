# frozen_string_literal: true

require 'json'
require 'stackprof'
require 'ruby-prof'
require 'benchmark'
require 'memory_profiler'
require 'vernier'

require_relative '../task-2'

file_path = './datasets/data_large.txt'

# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#   work(file_path)
# end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

# printer = RubyProf::DotPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

# RubyProf.measure_mode = RubyProf::WALL_TIME
#
# result = RubyProf.profile do
#   work(file_path)
# end
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

###############

# StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump') do
#   work(file_path)
# end

# profile = StackProf.run(mode: :object, raw: true) do
#   work(file_path)
# end

# File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

# profile = StackProf.run(mode: :wall, raw: true) do
#   work(file_path)
# end
#
# File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

#####################

# report = MemoryProfiler.report do
#   work(file_path)
# end
# report.pretty_print(color_output: true, scale_bytes: true)

################

Vernier.run(out: 'time_profile.json') do
  work(file_path)
end
