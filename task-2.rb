# Deoptimized version of homework task

require 'oj'
# require 'pry'

def work(filename='data.txt', disable_gc: false)
  GC.disable if disable_gc

  @total_users = 0
  @total_sessions = 0
  @all_browsers = []
  @unique_browsers_count = 0

  File.write('result.json', '{"usersStats":{')
  @report_file = File.open('result.json', 'a')

  File.foreach(filename) do |line|
    fields = line.split(',')
    case fields[0]
    when 'user'
      write_user_data unless @total_users == 0
      parse_user(fields)
    when 'session'
      parse_session(fields)
    end
  end
  write_user_data(true)
  add_stats
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(fields)
  @user_sessions_count = 0
  @user_total_time = 0
  @user_max_time = 0
  @user_browsers = []
  @session_dates = []
  @total_users += 1

  @full_name = "#{fields[2]} #{fields[3]}"
end

def parse_session(fields)
  @user_sessions_count += 1
  @total_sessions += 1
  session_time = fields[4].to_i
  @user_total_time += session_time
  @user_max_time = [@user_max_time, session_time].max
  current_browser = fields[3].upcase
  @user_browsers << current_browser
  @all_browsers << current_browser unless @all_browsers.include?(current_browser)
  @session_dates << fields[5].chomp
  @used_ie = @user_browsers.map{|s| s.match?(/INTERNET EXPLORER/) }.any?
  @always_chrome = @used_ie ? false : @user_browsers.all?{|s| s.match?(/CHROME/)}
end

def write_user_data(last=false)
  @user_stats = {}
  @user_stats["sessionsCount"] = @user_sessions_count
  @user_stats["totalTime"] = "#{@user_total_time} min."
  @user_stats["longestSession"] = "#{@user_max_time} min."
  @user_stats["browsers"] = @user_browsers.sort.join(', ')
  @user_stats["usedIE"] = @used_ie
  @user_stats["alwaysUsedChrome"] = @always_chrome
  @user_stats["dates"] = @session_dates.sort.reverse
  closing_char = last ? "}," : ","
  @report_file.puts "\"#{@full_name}\":#{Oj.dump(@user_stats)}#{closing_char}"
end

def add_stats
  stats = {}
  stats["totalUsers"] = @total_users
  stats["totalSessions"] = @total_sessions
  stats["allBrowsers"] = @all_browsers.sort.join(',')
  stats["uniqueBrowsersCount"] = @all_browsers.count
  @report_file.puts "#{Oj.dump(stats).gsub('}', '').gsub('{', '')}}"
  @report_file.close
end
