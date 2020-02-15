# gem install kalibera
require 'benchmark/ips'
require 'benchmark'
require 'byebug'

# объём памяти RAM, выделенной процессу в настоящее время
def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

puts "Start"

puts "Memory using before open file and rewrite it #{print_memory_usage}"
file_write = File.new('tmp.txt', 'w')
File.open("files/data_large.txt") do |f|
  f.each do
    puts f
    file_write.puts(f)
  end
end
puts "Memory using after rewrite file from file_read to file_write #{print_memory_usage}"
file_write.close
puts "Memory using after close file_write #{print_memory_usage}"
File.delete('tmp.txt')
puts "Memory using after deleting file_write #{print_memory_usage}"

# ===============
# puts "Memory using before open file for read #{print_memory_usage}"
# file_read = open 'files/data_large.txt'
# puts "Memory using after open file for read #{print_memory_usage}"
# puts "Memory using before create file for write #{print_memory_usage}"
# file_write = File.new('tmp.txt', 'w')
# puts "Memory using after create file for write #{print_memory_usage}"

# while line = file_read.gets&.chomp
#   file_write.puts(line)
# end
# puts "Memory using after rewrite file from file_read to file_write #{print_memory_usage}"
# file_write.close
# puts "Memory using after close file_write #{print_memory_usage}"
# File.delete('tmp.txt')
# puts "Memory using after deleting file_write #{print_memory_usage}"
# ==========
# puts "rss before file read: #{print_memory_usage}"

# File.read('files/data_large.txt')
# puts "rss after file read: #{print_memory_usage}"
# puts "rss before file splitted: #{print_memory_usage}"
# splitted = file.split("\n")
# puts "rss after file splitted: #{print_memory_usage}"


# puts "rss before open/read: #{print_memory_usage}"
# File.open('files/data_large.txt').read.each do |line| line end
# puts "rss after open/read: #{print_memory_usage}"

# puts "rss before readlines: #{print_memory_usage}"
# File.readlines('files/data_large.txt').each do |line| byebug end
# puts "rss after readlines: #{print_memory_usage}"

# time = Benchmark.realtime do
#   File.read('files/data_large.txt').each_char do |l|
#     if l == "\n"
#       array_lines << line
#     else
#       line << l
#     end
#   end
# end
# puts "Finish in #{time.round(2)}"


# report << "rss before empty string and array_lines created: #{print_memory_usage}"
# line = ''
# array_lines = []

# time = Benchmark.realtime do
#   File.read('files/data_large.txt').each_char do |l|
#     if l == "\n"
#       array_lines << line
#     else
#       line << l
#     end
#   end
# end
# puts "Finish in #{time.round(2)}"
# report << "rss after array_lines filled: #{print_memory_usage}"

puts "Making full GC..."
GC.start(full_mark: true, immediate_sweep: true)

puts "rss after GC: #{print_memory_usage}"


# def read_file_with_split(file='files/data.txt')
#   File.read(file).split("\n").each do |row|
#     row
#   end
# end

# def read_file_with_each_char(file='files/data.txt')
#   line = ''
#   File.read(file).each_char do |l|
#     if l == "\n"
#       line
#     else
#       line << l
#     end
#   end
# end

# def read_file_with_shift(file='files/data.txt')
#   lines = File.read(file).split("\n")
#   lines.shift while lines.count > 0
# end


#  Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)

#   x.report('read_file_with_split') { read_file_with_split }
#   x.report('read_file_with_each_char') { read_file_with_each_char }
#   x.report('read_file_with_shift') { read_file_with_shift }
#   x.compare!
# end

# def iterate_array(array)
#   array.each { |i| }
# end

# def iterate_hash(hash)
#   hash.each { |i| }
# end

# Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)

#   array_1000 = (1..1000).to_a
#   hash_1000 = Hash[*(1..2000).to_a]

#   x.report('generate_array from 1000 rows') { iterate_array(array_1000) }
#   x.report('generate hash from 1000 rows') { iterate_hash(hash_1000) }
#   x.compare!
# end



# def create_array(size)
#   Array.new(size){ |index| [0, 0, 0, [], nil, nil, []] }

#   # {
#   #   sessionsCount: 0,
#   #   totalTime: 0,
#   #   longestSession: 0,
#   #   browsers: [],
#   #   usedIE: false,
#   #   alwaysUsedChrome: true,
#   #   dates: []
#   # }
# end


# Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)

#   SIZE = [10, 100, 1000, 10_000, 100_000, 1000_000]

#   SIZE.each { |size| x.report("create array with #{size} users") { create_array(size) } }
#   x.compare!
# end

# SIZE = 100_000

# def work_with_while
#   a = []
#   i = 0
#   while i <= SIZE
#     i += 1
#     a << i
#   end
# end

# def work_with_loop
#   a = []
#   i = 0
#   loop do
#     break if i == SIZE
#     i += 1
#     a << i
#   end
# end

# Benchmark.ips do |x|
#   # The default is :stats => :sd, which doesn't have a configurable confidence
#   # confidence is 95% by default, so it can be omitted
#   x.config(:stats => :bootstrap, :confidence => 99)

#   x.report("while") { work_with_while }
#   x.report("loop") { work_with_loop }
#   x.compare!
# end
