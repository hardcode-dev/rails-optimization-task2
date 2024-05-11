require_relative 'task-2'

work(file_name: 'data.txt')

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
