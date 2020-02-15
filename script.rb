require 'memory_profiler'
require 'ruby-prof'
require_relative 'task-2.rb'

def profile_memory
  memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i

  yield

  memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i

  used_memory = ((memory_usage_after - memory_usage_before) / 1024.0).round(2)
  puts "Memory usage: #{used_memory} MB"
end

def profile_gc
  GC.start
  before = GC.stat(:total_freed_objects)
  yield
  GC.start
  after = GC.stat(:total_freed_objects)

  puts "Objects Freed: #{after - before}"
end

def memory_profile
  report = MemoryProfiler.report do
    Report.new.work(filename: 'data_large_100000.txt')
  end
  report.pretty_print(scale_bytes: true)
end

def profile
  profile_memory do
    profile_gc do
      Report.new.work(filename: 'data_large_100000.txt')
    end
  end
end

def report
  RubyProf.measure_mode = RubyProf::MEMORY

  report = RubyProf.profile do
    Report.new.work(filename: 'data_large_100000.txt')
  end

  printer = RubyProf::FlatPrinter.new(report)
  printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

  printer = RubyProf::GraphHtmlPrinter.new(report)
  printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

  printer = RubyProf::CallStackPrinter.new(report)
  printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
end

def speed_test
  RubyProf.measure_mode = RubyProf::WALL_TIME 

  result = RubyProf.profile do  
    Report.new.work(filename: 'data_large.txt')  
  end 

  printer = RubyProf::CallStackPrinter.new(result) 
  printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
end

profile

memory_profile

report

# speed_test
