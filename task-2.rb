# frozen_string_literal: true

# Deoptimized version of homework task

require 'oj'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  User.new(
    attributes: {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4]
    },
    sessions: []
  )
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def push_user_stats(browsers, oj_stream, user, user_key)
  oj_push(
    oj_stream,
    user_key,
    # Собираем количество сессий по пользователям
    'sessionsCount' => user.sessions.count,
    # Собираем количество времени по пользователям
    'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.',
    # Выбираем самую длинную сессию пользователя
    'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => browsers.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
  )
end

def collect_user_stat(oj_stream, user)
  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
  browsers = user.sessions.map { |s| s['browser'].upcase }
  push_user_stats(browsers, oj_stream, user, user_key)
end

def oj_push(stream, key, value)
  stream.push_key(key)
  stream.push_value(value)
end

def work(file_name = 'data.txt')
  last_user = nil
  total_users_count = 0
  total_sessions_count = 0
  # Подсчёт количества уникальных браузеров
  uniqueBrowsers = Set.new

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

  File.open('result.json', 'w') do |f|
    oj_stream = Oj::StreamWriter.new(f)
    # Статистика по пользователям
    oj_stream.push_object
    oj_stream.push_key('usersStats')
    oj_stream.push_object

    File.foreach(file_name, chomp: true) do |line|
      fields = line.split(',')

      case fields[0]
      when 'user'
        collect_user_stat(oj_stream, last_user) if last_user
        last_user = parse_user(fields)
        total_users_count += 1
      when 'session'
        session = parse_session(fields)
        last_user.sessions << session
        uniqueBrowsers << session['browser']
        total_sessions_count += 1
      end
    end

    collect_user_stat(oj_stream, last_user) if last_user
    oj_stream.pop

    oj_push(oj_stream, 'totalUsers', total_users_count)
    oj_push(oj_stream, 'uniqueBrowsersCount', uniqueBrowsers.count)
    oj_push(oj_stream, 'totalSessions', total_sessions_count)
    oj_push(oj_stream, 'allBrowsers', uniqueBrowsers.map(&:upcase).sort.uniq.join(','))

    oj_stream.pop
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
