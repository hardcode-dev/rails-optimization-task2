# frozen_string_literal: true

require 'json'
require 'set'

def parse_line(line)
  type, id, *params = line.split(',')
  [type, id, *params]
end

def initialize_user(params)
  {
    user_key: "#{params[0]} #{params[1]}",
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    usedIE: false,
    alwaysUsedChrome: true,
    dates: [],
    browsers: []
  }
end

def update_user_with_session(user, browser, time, date)
  user[:browsers] << browser
  user[:usedIE] ||= browser.include?('INTERNET EXPLORER')
  user[:alwaysUsedChrome] &&= browser.include?('CHROME')
  user[:totalTime] += time.to_i
  user[:sessionsCount] += 1
  user[:longestSession] = [user[:longestSession], time.to_i].max
  user[:dates] << date
end

def build_user_stat(user)
  {
    sessionsCount: user[:sessionsCount],
    totalTime: "#{user[:totalTime]} min.",
    longestSession: "#{user[:longestSession]} min.",
    browsers: user[:browsers].sort.join(', '),
    usedIE: user[:usedIE],
    alwaysUsedChrome: user[:alwaysUsedChrome],
    dates: user[:dates].sort.reverse
  }.to_json
end

def work(file_path, disable_gc = false)
  GC.disable if disable_gc

  unique_browsers = Set.new
  total_users = 0
  total_sessions = 0
  current_user = nil
  is_first_user = true

  File.open('spec/fixtures/files/result.json', 'w') do |result|
    result.write('{"usersStats":{')

    File.foreach(file_path, chomp: true) do |line|
      type, _id, *params = parse_line(line)

      if type == 'user'
        if current_user
          result.write(',') unless is_first_user
          result.write("\"#{current_user[:user_key]}\":#{build_user_stat(current_user)}")
          is_first_user = false
        end

        current_user = initialize_user(params)
        total_users += 1
      elsif type == 'session'
        browser = params[1].upcase
        update_user_with_session(current_user, browser, params[2], params[3])
        unique_browsers.add(browser)
        total_sessions += 1
      end
    end

    if current_user
      result.write(',') unless is_first_user
      result.write("\"#{current_user[:user_key]}\":#{build_user_stat(current_user)}")
    end

    result.write('},')
    result.write("\"totalUsers\":#{total_users},")
    result.write("\"uniqueBrowsersCount\":#{unique_browsers.count},")
    result.write("\"totalSessions\":#{total_sessions},")
    result.write("\"allBrowsers\":\"#{unique_browsers.sort.join(',')}\"")
    result.write('}')
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
