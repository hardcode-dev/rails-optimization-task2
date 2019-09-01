require 'ruby-prof'
RubyProf.measure_mode = RubyProf::MEMORY
# GC.disable
# require 'memory_profiler'

require './task-2.rb'

if ARGV.any?
  puts "process #{ARGV.first} ..."

  # report = MemoryProfiler.report do
  result = RubyProf.profile do
    work(ARGV.first)
  end

  printer = RubyProf::CallTreePrinter.new(result)
  printer.print(path: 'ruby_prof_reports_memory', profile: 'profile')

  # printer = RubyProf::FlatPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))
  #
  # printer = RubyProf::GraphHtmlPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
  #
  # printer = RubyProf::CallStackPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/call_stack.html', 'w+'))

  puts "... processed #{ARGV.first} by profile"

  # report.pretty_print(scale_bytes: true)
else
  puts 'no file to process'
end
