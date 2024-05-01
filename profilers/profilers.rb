# frozen_string_literal: true

require 'json'
require 'stackprof'
require 'ruby-prof'
require 'benchmark'
require 'memory_profiler'

require_relative '../task-2'

file_path = './datasets/data1000.txt'

# RubyProf.measure_mode = RubyProf::WALL_TIME

# result = RubyProf.profile do
#   WorkV5.work(file_path)
# end

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))

# ###############

# RubyProf.measure_mode = RubyProf::WALL_TIME

# result = RubyProf.profile do
#   WorkV5.work(file_path)
# end

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

###############

# profile = StackProf.run(mode: :wall, raw: true) do
#   work(file_path)
# end

# File.write('stackprof_reports/stackprof.json', JSON.generate(profile))

report = MemoryProfiler.report do
  work(file_path)
end
report.pretty_print(scale_bytes: true)