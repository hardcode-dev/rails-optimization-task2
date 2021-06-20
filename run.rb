require 'ruby-prof'
require_relative 'task-2'
require_relative 'task-2-optimized'
require 'memory_profiler'

time = Time.now
ParserOptimized.work('data_large.txt')
puts "time: #{(Time.now - time).to_i} sec"

# report = MemoryProfiler.report do
#   ParserOptimized.work('data/data_10.txt')
# end
#
# report.pretty_print scale_bytes: true

# ------------------------
#
# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile(track_allocations: true) do
#   ParserOptimized.work('data_500000.txt')
# end
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('reports/ruby-prof-memory.html', 'w+'))
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'reports', profile: 'ruby-prof-call-tree')
#
# exec "open #{File.absolute_path('reports/ruby-prof-memory.html')}"
