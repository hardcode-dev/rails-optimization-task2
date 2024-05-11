# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

  USER_COLUMNS = %w[id first_name last_name age].freeze
  SESSION_COLUMNS = %w[user_id session_id browser time date].freeze

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def collect_stats_from_users(report:, user:, sessions:, report_file:, &block)
  user_stats = {
    'sessionsCount' => 0,
    # Собираем количество времени по пользователям
    'totalTime' => 0,
    # Выбираем самую длинную сессию пользователя
    'longestSession' => 0,
    # Браузеры пользователя через запятую
    'browsers' => [],
    # Хоть раз использовал IE?
    'usedIE' => false,
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => false,
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => []
  }

  report['totalUsers'] += 1

  sessions.each do |session|
    session['time'] = session['time'].to_i
    session['browser'].upcase!

    user_stats['sessionsCount'] += 1
    user_stats['totalTime'] += session['time']
    user_stats['browsers'] << session['browser']

    if user_stats['longestSession'] < session['time']
      user_stats['longestSession'] = session['time']
    end

    report['allBrowsers'] << session['browser']
    report['totalSessions'] += 1

    user_stats['usedIE'] ||= session['browser'].match?(/INTERNET EXPLORER/)
    user_stats['alwaysUsedChrome'] &&= session['browser'].match?(/CHROME/)
    user_stats['dates'] << session['date']
  end

  user_stats['browsers'] = user_stats['browsers'].sort!.join(', ')
  user_stats['totalTime'] = user_stats['totalTime'].to_s << ' min.'
  user_stats['longestSession'] = user_stats['longestSession'].to_s << ' min.'
  user_stats['dates'].sort! { |d1, d2| d2 <=> d1 }

  report_file.write(',') if report['totalUsers'] > 1
  report_file.write({"#{user['first_name']} #{user['last_name']}" => user_stats}.to_json[1..-2])
end

def work(file_name: 'data.txt')
  # Статистика по пользователям
  report = {
    'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => Set.new,
  }

  report_file = File.open('result.json', 'a')

  user = {}
  sessions = []

  report_file.write('{"usersStats":{' )

  File.foreach(file_name, chomp: true) do |line|
    if line.start_with?('session')
      sessions << parse({}, SESSION_COLUMNS, line)
    else
      work_partial(user:, sessions:, report:, report_file:)

      parse(user, USER_COLUMNS, line)
    end
  end

  work_partial(user:, sessions:, report:, report_file:)

  report['allBrowsers'] = report['allBrowsers'].to_a.sort!
  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = report['allBrowsers'].size
  report['allBrowsers'] = report['allBrowsers'].join(',')

  report_file.write("},#{report.to_json[1..]}\n")
  report_file.close
end

def parse(object, columns, line)
  col_index = -2

  line.split(',') do |col|
    col_index += 1
    next if col_index < 0

    object[columns[col_index]] = col
  end

  object
end

def work_partial(user:, sessions:, report:, report_file: nil)
  return if user.empty?
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

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report:, user:, sessions:, report_file:)

  sessions.clear
  user.clear
end
