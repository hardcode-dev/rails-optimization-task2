# frozen_string_literal: true

# Optimized version of homework task

require 'set'
require 'oj'

def work(file_name = 'data_large.txt')
  users_count = 0
  sessions_count = 0
  user_sessions = []
  user_name = nil
  unique_browsers = Set.new
  report_file = File.new('result.json', 'w')
  report_file.write('{"usersStats":{')

  File.foreach(file_name, chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users_count += 1
      if user_name
        process_user(user_name, user_sessions, report_file)
        user_sessions = []
      end
      user_name = "#{cols[2]} #{cols[3]}"
    else
      sessions_count += 1
      session = parse_session(cols)
      user_sessions << session
      unique_browsers << session['browser']
    end
  end

  # Parse last user
  process_user(user_name, user_sessions, report_file)

  # Save Common stats
  report_file.write("\"totalUsers\":", users_count, ",",
                    "\"uniqueBrowsersCount\":", unique_browsers.count, ",",
                    "\"totalSessions\":", sessions_count, ",",
                    "\"allBrowsers\":\"", unique_browsers.sort.join(','), "\"}}\n"
  )
  report_file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_session(cols)
  {'browser' => cols[3].upcase,
   'time' => cols[4],
   'date' => cols[5]}
end

def process_user(full_name, sessions, report_file)
  report_file.write("\"#{full_name}\"", ":")
  stats = session_stat(sessions)
  report_file.write("#{Oj.dump(stats)}", ',')
end

def session_stat(sessions)
  session_time = sessions.map { |s| s['time'].to_i }
  session_browser = sessions.map { |s| s['browser'] }
  {'sessionsCount' => sessions.count,
   'totalTime' => "#{session_time.sum} min.",
   'longestSession' => "#{session_time.max} min.",
   'browsers' => session_browser.sort.join(', '),
   'usedIE' => session_browser.any? { |b| b =~ /INTERNET EXPLORER/ },
   'alwaysUsedChrome' => session_browser.all? { |b| b =~ /CHROME/ },
   'dates' => sessions.map { |s| s['date'] }.sort.reverse}
end

# work
