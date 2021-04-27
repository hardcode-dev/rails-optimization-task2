# frozen_string_literal: true

FILE_NAME = 'data.txt'

require 'json'
require 'pry'
require 'date'

require 'progress_bar'
require 'awesome_print'

require_relative 'user.rb'

USER_SIGN = 'user'.ord



def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(limit: nil, file_name: FILE_NAME)
  users = []
  sessions = []
  user = nil

  File.open(file_name).each_line.with_index do |line, ix|
    break if limit && ix >= limit

    line.chop!
    if line.ord == USER_SIGN
      user = User.new(line)
      users.push user
    else
      session = parse_session(line)
      user.add_session session
      sessions.push session
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

  report['usersStats'] = {}

  users.each do |user|
    report['usersStats'][user.key] = user.stats
  end

  File.write('result.json', "#{report.to_json}\n")
end
