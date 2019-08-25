# require 'ruby-prof'
# RubyProf.measure_mode = RubyProf::WALL_TIME
# GC.disable

require './task-2.rb'

if ARGV.any?
  puts "process #{ARGV.first} ..."
  time = Benchmark.realtime do
    # result = RubyProf.profile do
    work(ARGV.first)
    # end
    # printer = RubyProf::CallStackPrinter.new(result)
    # printer.print(File.open('ruby_prof_reports/call_stack.html', 'w+'))

    # printer4 = RubyProf::CallTreePrinter.new(result)
    # printer4.print(:path => "ruby_prof_reports", :profile => 'callgrind')
  end
  puts "... processed #{ARGV.first} in #{time} sec"
else
  puts 'no file to process'
end
