require 'ruby-prof'
require 'stackprof'
require 'memory_profiler'
require_relative '../task-2'

file_path = 'tmp_data/data_100000.txt'

# puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
# work(file_path, disable_gc: false)
# puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
# GC.start(full_mark: true, immediate_sweep: true)


report = MemoryProfiler.report do
  work(file_path, disable_gc: false)
end
puts "MemoryProfiler.report"
puts report.pretty_print(scaly_bytes: true)


StackProf.run(mode: :object, out: './reports/stackprof.dump', raw: true) do
  work(file_path, disable_gc: false)
end
puts "StackProf"
# stackprof reports/stackprof.dump --method 'Object#work'

RubyProf.measure_mode = RubyProf::ALLOCATIONS

result = RubyProf.profile do
  work(file_path, disable_gc: false)
end


puts "RubyProf::FlatPrinter"
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open('./reports/flat.txt', 'w+'))
# printer.print(STDOUT)

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.open('./reports/graph.html', 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.open('./reports/callstack.html', 'w+'))

