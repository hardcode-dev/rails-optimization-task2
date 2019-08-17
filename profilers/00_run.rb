# ruby profilers/00_run.rb
require_relative '../config/environment'

puts "Memory usage before: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

p Benchmark.measure { Task.new.work }

puts "Memory usage after: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

result_file_path = 'data/result.json'
File.delete(result_file_path) if File.exist?(result_file_path)
