require 'ruby-prof'
require 'memory_profiler'
require_relative '../task-2'

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

ReportGenerate.new.work(ENV['FILENAME'] || 'data.txt')

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
