


require_relative 'task-2'


mem = `ps -o rss= -p #{Process.pid}`.to_i / 1024

puts "MEMORY USAGE: %d MB (#{mem})"


Work.new('data_large.txt').work


mem = `ps -o rss= -p #{Process.pid}`.to_i / 1024

puts "MEMORY USAGE: %d MB (#{mem})"