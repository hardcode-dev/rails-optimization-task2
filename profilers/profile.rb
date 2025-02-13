# frozen_string_literal: true

require 'fileutils'
require 'memory_profiler'
require 'ruby-prof'
require 'stackprof'
require_relative '../task-2'

REPORTS_DIR = 'reports'
FileUtils.mkdir_p(REPORTS_DIR)

# path = "data/data#{ARGV[0] || 50000}.txt"
path = 'data_large.txt'
mode = ARGV[0] || 'memory_profiler'

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

when 'ruby-prof'
  profile = RubyProf::Profile.new(measure_mode: RubyProf::MEMORY)

  result = profile.profile do
    work(path)
  end
  printer = RubyProf::CallTreePrinter.new(result)
  printer.print(path: REPORTS_DIR, profile: 'callgrind')

else
  puts "Invalid mode: #{mode}. Use 'flat', 'graph', 'callstack', 'stackprof' or 'callgrind'."
  exit 1
end
