require 'byebug'

def work(file_name = 'data.txt')
  if File.exist?(file_name)
    lines_count = `wc -l < "#{file_name}"`.to_i
  end

  File.open(file_name, 'r') do |file|
    (0...lines_count).each do |line_number|
      line = file.gets
      parse(line)
    end
  end
end

def parse(line)
  fields = line.split(',')

  case fields[0]
  when 'user'
    puts "user id #{fields[1]}"
  when 'session'
    puts "session id #{fields[2]}"
  end
end

work('data_small.txt')
