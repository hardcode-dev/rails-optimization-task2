# Deoptimized version of homework task

require 'json'
# require 'minitest/autorun'
require 'memory_profiler'
require 'ruby-prof'
require './work'
require 'pry'


# result = RubyProf.profile do
# end

# На этот раз профилируем не allocations, а объём памяти!
# RubyProf.measure_mode = RubyProf::MEMORY

# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'ruby_prof_reports', profile: 'profile')

# report = MemoryProfiler.report do
#   work('data_large_sample.txt', gc: true)
# end
# report.pretty_print(scale_bytes: true)
# work('data_large.txt', gc: true)

thread1 = Thread.new do
  p "start"
  time = Time.now
  work('data_large.txt', gc: true)
  after = Time.now
  p after - time
end

Thread.new do
  loop do
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    sleep 1
  end
end

thread1.join


