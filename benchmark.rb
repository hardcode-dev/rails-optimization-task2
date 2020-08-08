# frozen_string_literal: true

require_relative 'task-2'

ROWS_COUNT = 50000
FILENAME = "data_small.txt"

`head -n #{ROWS_COUNT} data_large.txt > #{FILENAME}`

time = Time.now

work(filename: FILENAME, gc: false)

`rm #{FILENAME}`
