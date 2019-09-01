require_relative '../task-2.rb'
require 'benchmark'

# RSS - Resident Set Size
# объём памяти RAM, выделенной процессу в настоящее время
def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end


puts "Start"
puts "rss before array allocation: #{print_memory_usage}"

time = Benchmark.realtime do
  puts "rss before concatenation: #{print_memory_usage}"

  array = []
  IO.foreach('data/data_large.txt') do |line|
    array << line.split(",")
  end

  GC.start(full_mark: true, immediate_sweep: true)
  puts "rss after concatenation: #{print_memory_usage}"
end

puts "Finish in #{time.round(2)}"

