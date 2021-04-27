# frozen_string_literal: true

require_relative 'task-2'
FILENAME = 'data_assimpt.txt'

log = ['Assimptotics results:']

%w[1000000 1500000 2000000].each do |num_rows|
  puts "Started #{num_rows}"
  if system("head -n #{num_rows} data_large.txt > #{FILENAME}") && (`wc -l < #{FILENAME}`.strip == num_rows)
    start_time = Time.now.to_i
    work(FILENAME)
    end_time = Time.now.to_i - start_time
    log << "#{num_rows}: #{end_time} sec; MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end
  File.delete(FILENAME) if File.exist?(FILENAME)
end
puts log
