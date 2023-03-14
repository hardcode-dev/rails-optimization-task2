# frozen_string_literal: true
# Deoptimized version of homework task

require 'json'
require 'pry'
require 'set'

def write_user_data(json_file, user_key, data, last)
  json_file.write("\"#{user_key}\":#{data.to_json}")
  if last
    json_file.write('},')
  else
    json_file.write(',')
  end
end

def work(file:)
  json_file = File.new('result.json', 'w')
  total_user_count = 0
  total_session_count = 0
  total_browsers = Set.new

  user_key = nil
  user_sessions_count = 0
  user_total_time = 0
  user_longest = 0
  user_browsers = []
  user_used_ie = false
  user_always_chrome = true
  user_dates = []

  json_file.write('{"usersStats":{')
  File.foreach(file, chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      if user_key
        data = {
          sessionsCount: user_sessions_count,
          totalTime: "#{user_total_time} min.",
          longestSession: "#{user_longest} min.",
          browsers: user_browsers.sort!.join(', '),
          usedIE: user_used_ie,
          alwaysUsedChrome: user_always_chrome,
          dates: user_dates.sort!.reverse!,
        }
        write_user_data(json_file, user_key, data, false)

        # обнуляем значения для нового user-a
        user_sessions_count = 0
        user_total_time = 0
        user_longest = 0
        user_browsers = []
        user_used_ie = false
        user_always_chrome = true
        user_dates = []
      end
      total_user_count += 1
      user_key = "#{cols[2]} #{cols[3]}"

      next
    end

    browser = cols[3].upcase
    time = cols[4].to_i
    user_browsers << browser
    total_browsers << browser
    user_total_time += time
    user_longest = time if time > user_longest
    user_used_ie ||= browser.start_with?('INTERNET EXPLORER')
    if user_always_chrome
      user_always_chrome = browser.start_with?('CHROME')
    end
    user_dates << cols[5]
    user_sessions_count += 1
    total_session_count += 1
  end
  data = {
    sessionsCount: user_sessions_count,
    totalTime: "#{user_total_time} min.",
    longestSession: "#{user_longest} min.",
    browsers: user_browsers.sort!.join(', '),
    usedIE: user_used_ie,
    alwaysUsedChrome: user_always_chrome,
    dates: user_dates.sort!.reverse!,
  }
  write_user_data(json_file, user_key, data, true)
  json_file.write("\"totalUsers\": #{total_user_count}, \"uniqueBrowsersCount\": #{total_browsers.count}, \"totalSessions\": #{total_session_count}, \"allBrowsers\": \"#{total_browsers.sort.join(',')}\"}")
  json_file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
