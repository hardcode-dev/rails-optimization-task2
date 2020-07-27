require_relative './task-2.rb'

file_name = ARGV[0] || './data/data4.txt'
if File.exist?(file_name)
  work(file_name)
else
  puts 'ФАЙЛ НЕ НАЙДЕН!'
end
