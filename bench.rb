# require_relative 'task-2.rb'
# require 'memory_profiler'
#
# report = MemoryProfiler.report do
#   work
# end
#
# report.pretty_print


require 'benchmark'

require 'ruby-prof'


# RubyProf.measure_mode = RubyProf::WALL_TIME

# require 'stackprof'
require_relative 'task-2.rb'

require 'memory_profiler'
# report = MemoryProfiler.report do
time = Benchmark.realtime do
  work('data_large.txt')
end

puts "Finish in #{time.round(2)}"
# end

# report.pretty_print



# result = RubyProf.profile do
#   work('data10000.txt')
# end
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/callstack.html', 'w+'))
