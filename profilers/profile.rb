# frozen_string_literal: true

require 'fileutils'
require 'memory_profiler'
require 'ruby-prof'
require 'stackprof'
require_relative '../task-2'

REPORTS_DIR = 'reports'
FileUtils.mkdir_p(REPORTS_DIR)

path = "data/data#{ARGV[0] || 50000}.txt"
# path = 'data_large.txt'
mode = ARGV[1] || 'memory_profiler'

case mode
when 'memory_profiler'
  report = MemoryProfiler.report do
    work(path)
  end
  report.pretty_print(scale_bytes: true)

when 'stackprof'
  StackProf.run(mode: :object, out: "#{REPORTS_DIR}/stackprof.dump", raw: true) do
    work(path)
  end
# when 'flat'
#   printer = RubyProf::FlatPrinter.new(result)
#   File.open("#{REPORTS_DIR}/flat.txt", 'w+') { |file| printer.print(file) }
#   puts "Flat profile report generated at #{REPORTS_DIR}/flat.txt"

# when 'callstack'
#   printer = RubyProf::CallStackPrinter.new(result)
#   File.open("#{REPORTS_DIR}/callstack.html", 'w+') { |file| printer.print(file) }
#   puts "CallStack report generated at #{REPORTS_DIR}/callstack.html"

# when 'stackprof_speedscope'
#   profile = StackProf.run(mode: :wall, raw: true) do
#     work(path, no_gc: true)
#   end
#   File.write("#{REPORTS_DIR}/stackprof_speedscope.json", JSON.generate(profile))

else
  puts "Invalid mode: #{mode}. Use 'flat', 'graph', 'callstack', 'stackprof' or 'callgrind'."
  exit 1
end
