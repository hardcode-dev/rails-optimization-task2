require_relative "./lib/user.rb"
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'
require 'benchmark'

# report = MemoryProfiler.report do
#  work(input_path: "./data/data_large.txt", output_path: "./tmp/result.json")
# end

# report.pretty_print(scale_bytes: true)

# StackProf.run(mode: :object, out: 'reports/stackprof_memory.dump', raw: true) do
#   work(input_path: "./data/data_sample.txt", output_path: "./result.json")
# end

# RubyProf.measure_mode = RubyProf::MEMORY

# result = RubyProf.profile do
#   work(input_path: './data/data_sample.txt', output_path: './result.json')
# end

# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open("./reports/memory_flat.txt", "w+"))

# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open("./reports/memory_graph.html", "w+"))

# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open("./reports/memory_callstack.html", "w+"))

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: './reports/', profile: 'profile')


Benchmark.bm(5) do |x|
  x.report { work(input_path: './data/data_large.txt', output_path: './tmp/result.json') }
end



# Allocated memory
# Iteration 0: 3.78 GB