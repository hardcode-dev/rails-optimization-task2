require 'json'
require 'set'
require 'tempfile'

require_relative 'user.rb'
require_relative 'session.rb'
require_relative 'report.rb'
require_relative 'generate_user_stat.rb'

def work(file_name = 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  data_file = File.new(file_name)
  result_file = File.new('result.json', 'w')
  Report.new(data_file, result_file).generate

  data_file.close
  result_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
