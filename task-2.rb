# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = /(\w+),(\w+),(\w+),(\w+),(\w+)/.match(user)

  {
    'id' => fields[2],
    'first_name' => fields[3],
    'last_name' => fields[4],
    'age' => fields[5]
  }
end

def parse_session(session)
  fields = /(\w+),(\w+),(\w+),([a-zA-Z0-9_ ]+),(\w+),([0-9-]+)/.match(session)

  {
    'user_id' => fields[2],
    'session_id' => fields[3],
    'browser' => fields[4],
    'time' => fields[5],
    'date' => fields[6]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end


def build_user_hash(session, sessions_users)
  if sessions_users[session['user_id']].nil?
    sessions_users[session['user_id']] = [session]
  else
    sessions_users[session['user_id']] << session
  end
end

def work(file_path = 'data.txt')
  file_lines = File.read(file_path).split("\n")
  
  users = []
  sessions = []
  sessions_users = {}

  file_lines.each do |line|
    is_user = line.start_with?('user')
    if is_user
      users << parse_user(line)
    else
      session = parse_session(line)
      sessions << session
      build_user_hash(session, sessions_users)
    end
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
  users_objects = []

  users.each do |user|
    attributes = user
    user_sessions = sessions_users[user['id']]
    user_object = User.new(attributes: attributes, sessions: user_sessions)
    users_objects << user_object
  end

  report['usersStats'] = {}

  collect_stats_from_users(report, users_objects) do |user|
    # Собираем количество сессий по пользователям
    { 'sessionsCount' => user.sessions.count,
    # Собираем количество времени по пользователям
    'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
    'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user.sessions.map{|s| s['date']}.sort.reverse }
  end


  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
