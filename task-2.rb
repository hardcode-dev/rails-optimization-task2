# Deoptimized version of homework task

require 'json'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

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

def collect_stats_from_users(report, users, sessions)
  users.each do |user|
    user_object = User.new(attributes: user, sessions: sessions[user['id']])
    user_key = "#{user_object.attributes['first_name']}" + ' ' + "#{user_object.attributes['last_name']}"
    user_sessions = user_object.sessions
    # next unless user_sessions

    browsers = user_sessions.map { |s| s['browser'] }
    report['usersStats'][user_key] ||= {
      'sessionsCount' => sessions_count(user_sessions),
      'totalTime' => total_time(user_sessions),
      'longestSession' => longest_session(user_sessions),
      'browsers' => browsers(browsers),
      'usedIE' => used_ie(browsers),
      'alwaysUsedChrome' => always_used_chrome(browsers),
      'dates' => dates(user_sessions)
    }
  end
end

def work(path = 'data.txt')
  users = []
  sessions = {}
  unique_browsers = Set.new
  sessions_count = 0
  report = {}

  File.foreach(path) do |line|
    data = line.chomp!.split(',')
    head = data.first
    if head == 'user'
      users << parse_user(data)
    elsif head == 'session'
      session = parse_session(data)
      sessions[session['user_id']] ||= []
      sessions[session['user_id']] << session

      unique_browsers.add session['browser']
      sessions_count += 1
    end
  end

  report['totalUsers'] = users.count
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = sessions_count
  report['allBrowsers'] = unique_browsers.sort.join(',')

  report['usersStats'] = {}

  collect_stats_from_users(report, users, sessions)

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  File.write('result.json', "#{report.to_json}\n")
end
