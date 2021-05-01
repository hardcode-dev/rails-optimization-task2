require_relative 'task-2'.freeze
require 'benchmark'

def work_for_file(file_name, mutex)
  Process.fork do
    work(file_name)
    mutex.synchronize do
      puts "For #{file_name}:"
      puts 'MEMORY USAGE: %d MB' % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    end
  end
end

def work_with_benchmark
  mutex = Mutex.new
  files = %w[data_100K.txt data_1M.txt data_large.txt]
  files.each { |file_name| work_for_file(file_name, mutex) }
  Process.waitall
end

work_with_benchmark
