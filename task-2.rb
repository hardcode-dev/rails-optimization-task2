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

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

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
    user_stats['sessionsCount'] += 1
    user_stats['totalTime'] += session['time']
    user_stats['browsers'] << session['browser']

    if user_stats['longestSession'] < session['time']
      user_stats['longestSession'] = session['time']
    end

    unless report['allBrowsers'].include?(session['browser'])
      report['allBrowsers'] << session['browser']
    end
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
    'allBrowsers' => [],
  }

  report_file = File.open('result.json', 'a')

  user = nil
  sessions = []

  report_file.write('{"usersStats":{' )

  File.foreach(file_name, chomp: true) do |line|
    cols = line.split(',')

    if cols[0] == 'session'
      sessions << parse_session(cols)
    else
      work_partial(user:, sessions:, report:, report_file:)

      user = parse_user(cols)
    end
  end

  work_partial(user:, sessions:, report:, report_file:)

  report['allBrowsers'].sort!
  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = report['allBrowsers'].size
  report['allBrowsers'] = report['allBrowsers'].join(',')

  report_file.write("},#{report.to_json[1..]}\n")
  report_file.close
end

def work_partial(user:, sessions:, report:, report_file: nil)
  return unless user
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
  user = nil
end
