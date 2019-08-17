require 'set'
require 'oj'

require_relative './task'

Task.new(data_file_path: './small.txt', result_file_path: './result.json').work
