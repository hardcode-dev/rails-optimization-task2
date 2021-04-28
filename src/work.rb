# frozen_string_literal: true

FILE_NAME = 'data.txt'
REPORT_FILE_NAME = 'result.json'

require 'json'
require 'pry'
require 'date'

require 'progress_bar'
require 'awesome_print'

require_relative 'user.rb'

USER_SIGN = 'user'.ord

def parse_session(session)
  session[/,([^,]+),(\d+),([\d-]+)$/]
  [(+$1).upcase!.freeze, $2.to_i, $3]
end

def write(fh, object, trailing_bracket = false)
  fh.write(object.to_json[1..(trailing_bracket ? -1 : -2)])
end

def write_user(fh, user)
  write(fh, { user.key => user.stats })
end

def work(limit: nil, file_name: FILE_NAME)
  browsers = []
  user_count = 0
  session_count = 0
  user = nil
  user_stats = {}

  File.open(REPORT_FILE_NAME, 'w') do |fh|
    fh.write('{"usersStats":{')
    File.open(file_name).each_line.with_index do |line, ix|
      break if limit && ix >= limit

      line.chop!
      if line.ord == USER_SIGN
        # user_stats[user.key] = user.stats unless user.nil?
        unless user.nil?
          write_user(fh, user)
          fh.write(',')
        end
        user = User.new(line)
        user_count += 1
      else
        browser, time, date = parse_session(line)
        browsers.push(browser) unless browsers.include?(browser)

        user.add_session(browser, time, date)
        session_count += 1
      end
    end
    write_user(fh, user) unless user.nil?
    fh.write('},')

    browsers.sort!

    write(fh, {
      totalUsers: user_count,
      uniqueBrowsersCount: browsers.count,
      totalSessions: session_count,
      allBrowsers: browsers.join(',')
    }, true)

    fh.write("\n")
  end
end
