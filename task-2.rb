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

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5].strip
  }
end

def collect_stats_from_users(report, users, session_objects)
  users.each do |user|
    user_object = User.new(attributes: user, sessions: session_objects[user['id']])
    user_key = "#{user_object.attributes['first_name']}" + ' ' + "#{user_object.attributes['last_name']}"
    sessions = user_object.sessions
    browsers = sessions.map { |s| s['browser'].upcase }
    report['usersStats'][user_key] ||= {
      'sessionsCount' => sessions_count(sessions),
      'totalTime' => total_time(sessions),
      'longestSession' => longest_session(sessions),
      'browsers' => browsers(browsers),
      'usedIE' => used_ie(browsers),
      'alwaysUsedChrome' => always_used_chrome(browsers),
      'dates' => dates(sessions)
    }
  end
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

def work(path = 'data.txt')
  users = []
  sessions = []

  File.foreach(path) do |line|
    cols = line.split(',')
    users << parse_user(line) if cols[0] == 'user'
    sessions << parse_session(line) if cols[0] == 'session'
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  report = {}

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = []
  sessions.each do |session|
    browser = session['browser']
    uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
  end

  report['uniqueBrowsersCount'] = uniqueBrowsers.count

  report['totalSessions'] = sessions.count

  report['allBrowsers'] =
    sessions
      .map { |s| s['browser'] }
      .map { |b| b.upcase }
      .sort
      .uniq
      .join(',')

  # Статистика по пользователям
  session_objects = {}
  sessions.each do |session|
    session_objects[session['user_id']] ||= []
    session_objects[session['user_id']] << session
  end
  report['usersStats'] = {}

  collect_stats_from_users(report, users, session_objects)

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  File.write('result.json', "#{report.to_json}\n")
end
