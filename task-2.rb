# frozen_string_literal: true

# Optimized version of homework task

require 'pry'
require 'date'
require 'json'

class User
  attr_reader :attributes, :sessions, :times, :browsers, :dates, :full_name

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @times = []
    @browsers = []
    @dates = []
    @full_name = "#{attributes['first_name']} #{attributes['last_name']}"
    fill_fields
  end

  def fill_fields
    sessions.each do |session|
      @times << session['time']
      @browsers << session['browser'].upcase
      @dates << session['date']
    end
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, user, &block)
  report['usersStats'][user.full_name] = block.call(user)
end

def work(file_name:, disable_gc: false)
  GC.disable if disable_gc

  file_lines = File.foreach(file_name)

  users = []
  sessions = []

  file_lines.each do |line|
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

  report['usersStats'] = {}

  # Статистика по пользователям
  session_by_user = sessions.group_by { |s| s['user_id'] }
  users.each do |user|
    user_sessions = session_by_user[user['id']]
    user_object = User.new(attributes: user, sessions: user_sessions)

    collect_stats_from_users(report, user_object) do |user|
      {
        # Собираем количество сессий по пользователям
        'sessionsCount' => user.sessions.size,
        # Собираем количество времени по пользователям
        'totalTime' => "#{user.times.sum} min.",
        # Выбираем самую длинную сессию пользователя
        'longestSession' => "#{user.times.max} min.",
        # Браузеры пользователя через запятую
        'browsers' => user.browsers.sort.join(', '),
        # Хоть раз использовал IE?
        'usedIE' => user.browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        # Всегда использовал только Chrome?
        'alwaysUsedChrome' => user.browsers.all? { |b| b.upcase =~ /CHROME/ },
        # Даты сессий через запятую в обратном порядке в формате iso8601
        'dates' => user.dates.sort.reverse
      }
    end
  end

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end