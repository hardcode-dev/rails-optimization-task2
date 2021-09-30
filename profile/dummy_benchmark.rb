require_relative '../task-2'

work('data/data_4000.txt')

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
