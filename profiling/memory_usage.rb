require_relative '../task-2'

Parser.new.work('../100000.txt')
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
