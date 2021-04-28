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
  session[/,([^,]+),(\d+),([\d-]+)$/]
  [(+$1).upcase!.freeze, $2.to_i, $3]
end

def work(limit: nil, file_name: FILE_NAME)
  browsers = []
  user_count = 0
  session_count = 0
  user = nil
  user_stats = {}

  File.open(file_name).each_line.with_index do |line, ix|
    break if limit && ix >= limit

    line.chop!
    if line.ord == USER_SIGN
      user_stats[user.key] = user.stats unless user.nil?
      user = User.new(line)
      user_count += 1
    else
      browser, time, date = parse_session(line)
      browsers.push(browser) unless browsers.include?(browser)

      user.add_session(browser, time, date)
      session_count += 1
    end
  end
  user_stats[user.key] = user.stats unless user.nil?

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

  report[:totalUsers] = user_count

  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = session_count

  browsers.sort!.uniq!

  report['allBrowsers'] = browsers.join(',')

  report['usersStats'] = user_stats

  File.write('result.json', "#{report.to_json}\n")
end
