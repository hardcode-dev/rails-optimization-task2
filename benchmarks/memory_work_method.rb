require_relative '../task-2.rb'
require 'benchmark'

# RSS - Resident Set Size
# объём памяти RAM, выделенной процессу в настоящее время
def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def report_gc_delta(before, after)
  puts "GCs Count: #{after[:count] - before[:count]}"
end

def print_object_space_count_objects
  puts "\ncount_objects: "
  pp ObjectSpace.count_objects
end

def old_stat
  @old_stat = GC.stat
  pp @old_stat
  print_object_space_count_objects
end

def new_stat
  @new_stat = GC.stat
  pp @new_stat
  print_object_space_count_objects
end

report = Report.new('data/data_large.txt')

puts "Start"
puts "rss before array allocation: #{print_memory_usage}"

time = Benchmark.realtime do
  puts "rss before #work: #{print_memory_usage}"
  old_stat

  report.work
  
  puts "rss after #work: #{print_memory_usage}"

  new_stat
  report_gc_delta(@old_stat, @new_stat)

end

puts "Finish in #{time.round(2)}"

