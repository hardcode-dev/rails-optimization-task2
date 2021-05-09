require 'ruby-prof'
require_relative 'task-2'
require_relative 'task-2-optimized'
require 'memory_profiler'

# RubyProf.measure_mode = RubyProf::ALLOCATIONS
#
# result = RubyProf.profile(track_allocations: true) do
#   ParserOptimized.work('data/data_1000.txt')
# end

report = MemoryProfiler.report do
  ParserOptimized.work('data_100000.txt')
end

report.pretty_print scale_bytes: true

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/ruby-prof-allocation.html', 'w+'))

# exec "open #{File.absolute_path('reports/ruby-prof-allocation.html')}"
