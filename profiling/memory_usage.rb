require_relative '../task-2'

Parser.new.work('../data_large.txt')
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
# puts GC.count
