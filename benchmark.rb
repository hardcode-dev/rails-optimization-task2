# frozen_string_literal: true

require_relative 'task-2'

# ROWS_COUNT = 500000
# FILENAME = "data_small.txt"
#
# `head -n #{ROWS_COUNT} data_large.txt > #{FILENAME}`
#
time = Time.now

work(filename: 'data_large.txt')

puts `ps -o rss= -p #{Process.pid}`.to_i / 1024

# `rm #{FILENAME}`
