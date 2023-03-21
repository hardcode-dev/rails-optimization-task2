# Deoptimized version of homework task

require 'json'
require 'date'

def parse_user(user_data)
  {
    'id' => user_data[1],
    'first_name' => user_data[2],
    'last_name' => user_data[3],
    'age' => user_data[4]
  }
end

def parse_session(session_data)
  {
    'user_id' => session_data[1],
    'session_id' => session_data[2],
    'browser' => session_data[3].upcase,
    'time' => session_data[4],
    'date' => session_data[5]
  }
end

# Собираем количество сессий по пользователям
def sessions_count(sessions)
  sessions.count
end

# Собираем количество времени по пользователям
def total_time(sessions)
  [sessions.sum { |s| s['time'].to_i }, 'min.'].join(' ')
end

# Выбираем самую длинную сессию пользователя
def longest_session(sessions)
  [sessions.max_by { |s| s['time'].to_i }['time'], 'min.'].join(' ')
end

# Браузеры пользователя через запятую
def browsers(browsers)
  browsers.sort.join(', ')
end

# Хоть раз использовал IE?
def used_ie(browsers)
  browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
end

# Всегда использовал только Chrome?
def always_used_chrome(browsers)
  browsers.all? { |b| b =~ /CHROME/ }
end

# Даты сессий через запятую в обратном порядке в формате iso8601
def dates(sessions)
  sessions.map { |s| s['date'] }.sort.reverse
end

def collect_stats_from_user(user_key, sessions)
  browsers = sessions.map { |s| s['browser'] }
  {
    user_key => {
      'sessionsCount' => sessions_count(sessions),
      'totalTime' => total_time(sessions),
      'longestSession' => longest_session(sessions),
      'browsers' => browsers(browsers),
      'usedIE' => used_ie(browsers),
      'alwaysUsedChrome' => always_used_chrome(browsers),
      'dates' => dates(sessions)
    }
  }
end

def work(path = 'data.txt')
  sessions = []
  user_key = ''

  unique_browsers = Set.new
  sessions_count = 0
  users_count = 0

  File.write('result.json', '{"usersStats":{')

  File.foreach(path) do |line|
    data = line.chomp!.split(',')
    head = data.first

    if head == 'user'
      if sessions.any?
        user_data = collect_stats_from_user(user_key, sessions)
        File.write('result.json', [user_data.to_json[1..-2], ','].join, mode: 'a')
        sessions.clear
      end

      user = parse_user(data)
      user_key = "#{user['first_name']} #{user['last_name']}"
      users_count += 1
    elsif head == 'session'
      session = parse_session(data)
      sessions << session

      sessions_count += 1
      unique_browsers.add session['browser']
    end
  end
  user_data = collect_stats_from_user(user_key, sessions)
  File.write('result.json', [user_data.to_json[1..-2], '},'].join, mode: 'a') if sessions.any?

  report = {}

  report['totalUsers'] = users_count
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions_count
  report['allBrowsers'] = unique_browsers.sort.join(',')

  File.write('result.json', report.to_json[1...], mode: 'a')

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
