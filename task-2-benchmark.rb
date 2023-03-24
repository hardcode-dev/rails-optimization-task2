require_relative 'task-2'
require 'benchmark'

Dir['data_part_*'].sort_by { |f| f[/\d+/].to_i }.each do |file_path|
  puts '===================='
  puts "File: #{file_path}"
  time = Benchmark.realtime { Work.new.work(file_path) }
  puts time.round(2)
end

puts '===================='
puts "File: large"
time = Benchmark.realtime { Work.new.work('data_large.txt') }
puts time.round(2)
