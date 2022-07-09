# frozen_string_literal: true

require 'minitest/autorun'
require 'date'
require 'oj'
require 'set'

def report_user(user_key, user_browsers, user_time, user_time_max, user_dates, user_sessions_count, is_last: false)
  report = {
    'sessionsCount' => user_sessions_count,
    'totalTime' => "#{user_time} min.",
    'longestSession' => "#{user_time_max} min.",
    'browsers' => user_browsers.sort!.join(', '),
    'usedIE' => user_browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => user_browsers.all? { |b| b =~ /CHROME/ },
    'dates' => user_dates.to_a.sort! { |a, b| b <=> a }
  }
  @outfile.write("\"#{user_key}\":")
  @outfile.write(Oj.dump(report), is_last ? '},' : ',')
end

def work(filename = 'data.txt', disable_gc: false)
  disable_gc ? GC.disable : GC.enable
  filename = ENV['DATA_FILE'] || filename

  @outfile = File.new('result.json', 'w')
  @outfile.write('{"usersStats":{')

  user_key = nil
  user_sessions_count = 0
  user_time = 0
  user_time_max = 0
  user_browsers = []
  user_dates = Set.new
  all_browsers = SortedSet.new
  users_count = 0
  sessions_count = 0

  File.foreach(ENV['DATA_FILE'] || filename, chomp: true) do |line|
    cols = line.split(',')
    case cols[0]
    when 'user'
      if user_key
        report_user(user_key, user_browsers, user_time, user_time_max, user_dates, user_sessions_count)
        user_sessions_count = 0
        user_time = 0
        user_time_max = 0
        user_browsers = []
        user_dates = []
      end
      user_key = "#{cols[2]} #{cols[3]}"
      users_count += 1
    when 'session'
      browser = cols[3].upcase!
      user_browsers << browser
      all_browsers << browser
      time = cols[4].to_i
      user_time += time
      user_time_max = time if time > user_time_max
      user_dates << cols[5]
      sessions_count += 1
      user_sessions_count += 1
    end
  end

  report_user(user_key, user_browsers, user_time, user_time_max, user_dates, user_sessions_count, is_last: true)

  all_browsers = all_browsers.to_a
  summary_report = {
    'totalUsers' => users_count,
    'uniqueBrowsersCount' => all_browsers.count,
    'totalSessions' => sessions_count,
    'allBrowsers' => all_browsers.join(',')
  }
  @outfile.write(Oj.dump(summary_report)[1..])
  @outfile.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
