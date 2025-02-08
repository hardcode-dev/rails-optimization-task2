require_relative 'task-2-with-argument.rb'

class MemoryUsageError < StandardError; end

COUNTERS = [1, 2, 4, 8, 16, 32]

COUNTERS.each do |counter|
  `head -n #{counter*1000} data_large.txt > data_small.txt`
  work('data_small.txt')
end

thread1 = Thread.new do
  work('data_large.txt')
end

Thread.new do
  loop do
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "MEMORY USAGE: %d MB" % (memory)
    sleep 1
    raise MemoryUsageError if memory >= 70
  end
end

thread1.join

# initial

# 1000   MEMORY USAGE: 33 MB
# 2000   MEMORY USAGE: 38 MB
# 4000   MEMORY USAGE: 53 MB
# 8000   MEMORY USAGE: 87 MB
# 16000  MEMORY USAGE: 158 MB
# 32000  MEMORY USAGE: 241 MB
