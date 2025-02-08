
require './work'

thread1 = Thread.new do
  time = Time.now
  work('data_large.txt', gc: true)
  after = Time.now
  puts "Time: #{after - time} seconds"
end

Thread.new do
  loop do
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    sleep 1
  end
end

thread1.join

puts "TOTAL MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
