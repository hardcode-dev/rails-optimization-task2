# frozen_string_literal: true

require 'json'
# require 'pry'
require 'date'
require 'set'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5].strip
  }
end

def write_user_stats(f, user, user_sessions, last = false)
  times = []
  dates = []
  browsers = []

  user_sessions.each do |s|
    times << s['time']
    browsers << s['browser']
    dates << s['date']
  end

  browsers = browsers.to_a

  report = {
    # Собираем количество сессий по пользователям
    'sessionsCount' => user_sessions.count,
    # Собираем количество времени по пользователям
    'totalTime' => times.sum.to_s + ' min.',
    # Выбираем самую длинную сессию пользователя
    'longestSession' => times.max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => browsers.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => dates.sort.reverse
   }

  to_write = "\"#{user['first_name']} #{user['last_name']}\":#{report.to_json}"
  to_write = to_write + ',' unless last

  f.puts to_write
end

def work(filename = nil)
  filename ||= ENV['DATA_FILE']

  total_users = 0
  total_sessions = 0
  unique_browsers = Set.new

  user = nil
  user_sessions = []
  line_type = nil
  prev_line_type = nil

  f = File.open('result.json', 'w+')
  f.puts('{"usersStats":{')

  File.foreach(filename).with_index do |line, i|
    cols = line.split(',')
    line_type = cols[0]

    if line_type == 'user' && prev_line_type != nil
      write_user_stats(f, user, user_sessions)
      user_sessions = []
    end
    prev_line_type = line_type

    if line_type == 'session'
      session = parse_session(cols)
      user_sessions << session
      total_sessions += 1

      unique_browsers << session['browser']
    elsif line_type == 'user'
      user = parse_user(cols)
      total_users += 1
    end
  end

  # Stats for the last user
  write_user_stats(f, user, user_sessions, _last = true)

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

  total_report = {
    totalUsers: total_users,
    uniqueBrowsersCount: unique_browsers.count,
    totalSessions: total_sessions,
    allBrowsers: unique_browsers.to_a.map(&:upcase).sort.join(',')
  }

  f.puts "},#{total_report.to_json[1..-1]}"
  f.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts "Done. Processed file #{filename}."
end
