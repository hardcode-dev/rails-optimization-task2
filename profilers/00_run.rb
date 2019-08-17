# ruby profilers/00_run.rb
require_relative '../config/environment'

GC.start

allocated_before = GC.stat(:total_allocated_objects)
freed_before = GC.stat(:total_freed_objects)
mem = GetProcessMem.new

puts "Memory usage before: #{mem.mb} MB."

p Benchmark.measure { Task.new.work }

mem = GetProcessMem.new
puts "Memory usage after: #{mem.mb} MB."

GC.start
allocated_after = GC.stat(:total_allocated_objects)
freed_after = GC.stat(:total_freed_objects)

puts "Total objects allocated: #{allocated_after - allocated_before}"
puts "Total objects freed: #{freed_after - freed_before}"

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
