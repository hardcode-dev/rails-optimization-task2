require 'ruby-prof'
require_relative '../task-2'

file_path = 'tmp_data/data_large.txt'


puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
work(file_path, disable_gc: true)
puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

RubyProf.measure_mode = RubyProf::WALL_TIME
result = RubyProf.profile do
  work(file_path, disable_gc: true)
end
printer = RubyProf::FlatPrinter.new(result)
printer.print(File.open("./reports/prof_flat.txt", 'w+'))