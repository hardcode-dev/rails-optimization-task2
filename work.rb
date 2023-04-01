require_relative 'task-2.rb'

file = ENV['DATA_FILE'] || 'data/data_large.txt'

work(
  file: file,
  disable_gc: false,
  progressbar_use: false
)