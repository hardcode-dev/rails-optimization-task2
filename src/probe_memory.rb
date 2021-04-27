# frozen_string_literal: true

FILE_NAME_LARGE = 'data_large.txt'
REPORT_PATH = './report'
LIMIT = 500_000
NO_LIMIT = nil

OPEN_CMD = RUBY_PLATFORM =~ /darwin/ ? 'open' : 'xdg-open'

require_relative 'work.rb'

def do_work(limit: LIMIT)
  work(limit: limit, file_name: FILE_NAME_LARGE)
end

at_exit do
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

do_work(limit: NO_LIMIT)
# do_work(limit: LIMIT)
