# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(id, first_name, last_name, age)
  {
    'id' => id,
    'first_name' => first_name,
    'last_name' => last_name,
    'age' => age,
  }
end

def parse_session(user_id, session_id, browser, time, date)
  {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser,
    'time' => time,
    'date' => date,
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(file_path, disable_gc: {})
  GC.disable if disable_gc

  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    type, id, param_1, param_2, param_3, param_4 = line.split(',')
    users << parse_user(id, param_1, param_2, param_3) if type == 'user'
    sessions << parse_session(id, param_1, param_2, param_3, param_4) if type == 'session'
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
    uniqueBrowsers << browser if uniqueBrowsers.all? { |b| b != browser }
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

  user_sessions = sessions.group_by { |session| session['user_id'] }
  users_objects = users.map do |user|
    User.new(attributes: user, sessions: user_sessions[user['id']] || [])
  end

  report['usersStats'] = {}

  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

    # Подготовим данные для сессий
    sessions = user.sessions
    times = sessions.map { |s| s['time'].to_i }
    browsers = sessions.map { |s| s['browser'].upcase }

    report['usersStats'][user_key] = {
      # Количество сессий
      'sessionsCount' => sessions.count,
      # Общее время
      'totalTime' => "#{times.sum} min.",
      # Самая длинная сессия
      'longestSession' => "#{times.max} min.",
      # Браузеры через запятую
      'browsers' => browsers.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => browsers.any? { |b| b.include?('INTERNET EXPLORER') },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => browsers.all? { |b| b.include?('CHROME') },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
    }
  end

  File.write('spec/fixtures/files/result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
