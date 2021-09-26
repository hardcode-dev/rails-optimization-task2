# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'set'
require 'dotenv/load'

#=====================================================
# MODELS
#=====================================================

class User
  attr_reader :first_name, :last_name, :stats

  def initialize(first_name, last_name)
    @first_name = first_name
    @last_name = last_name

    @stats = {
      sessions_count: 0,
      total_time: 0,
      longest_session: 0,
      browsers: [],
      used_ie: false,
      always_used_chrome: false,
      dates: []
    }
  end

  # Собираем количество сессий по пользователям
  # Собираем количество времени по пользователям
  # Выбираем самую длинную сессию пользователя
  # Браузеры пользователя через запятую
  # Хоть раз использовал IE?
  # Всегда использовал только Chrome?
  # Даты сессий через запятую в обратном порядке в формате iso8601

  def calculation_params(session)
    stats[:sessions_count] += 1
    stats[:total_time] += session.time
    stats[:longest_session] = session.time if session.time > stats[:longest_session]
    stats[:browsers] << session.browser
    stats[:used_ie] = true if session.browser == 'INTERNET EXPLORER'
    stats[:always_used_chrome] = true if session.browser == 'CHROME'
    stats[:dates] << session.date
  end
end

class Session
  attr_reader :browser, :time, :date

  def initialize(browser, time, date)
    @browser = browser.upcase!
    @time = time.to_i
    @date = date
  end
end

#=====================================================
# MAIN METHOD
#=====================================================

def work(filename = '')
  result_file = File.open('result.json', 'w')
  result_file.write('{"usersStats":{')

  total_sessions = 0
  all_browsers = Set.new
  users = []
  user = nil

  File.foreach(filename) do |line|
    cols = line.chomp!.split(',')

    if cols[0] == 'user'
      user = User.new(cols[2], cols[3])
      users << user
    end

    if cols[0] == 'session'
      session = Session.new(cols[3], cols[4], cols[5])

      total_sessions += 1
      all_browsers << session.browser

      user.calculation_params(session)
    end
  end

  users.each do |u|
    result_file.write("\"#{u.first_name} #{u.last_name}\":")
    result_file.write(u.stats.to_json)
    result_file.write('},')
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

  report = {
    totalUsers: users.count,
    uniqueBrowsersCount: all_browsers.count,
    totalSessions: total_sessions,
    allBrowsers: all_browsers.sort.join(',')
  }

  result_file.write("#{report.to_json}\n")
  result_file.close

  puts 'MEMORY USAGE: %d MB' % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

#=====================================================
# TEST
#=====================================================

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work('data.txt')
    expected_result = '{"usersStats":{"Leida Cira":{"sessions_count":6,"total_time":455,"longest_session":118,"browsers":["SAFARI 29","FIREFOX 12","INTERNET EXPLORER 28","INTERNET EXPLORER 28","SAFARI 39","INTERNET EXPLORER 35"],"used_ie":false,"always_used_chrome":false,"dates":["2016-10-23","2017-02-27","2017-03-28","2016-09-15","2017-09-27","2016-09-01"]}},"Palmer Katrina":{"sessions_count":5,"total_time":218,"longest_session":116,"browsers":["SAFARI 17","FIREFOX 32","CHROME 6","INTERNET EXPLORER 10","CHROME 13"],"used_ie":false,"always_used_chrome":false,"dates":["2016-10-21","2016-12-20","2016-11-11","2017-04-29","2016-12-28"]}},"Gregory Santos":{"sessions_count":4,"total_time":192,"longest_session":85,"browsers":["CHROME 35","SAFARI 49","FIREFOX 47","CHROME 20"],"used_ie":false,"always_used_chrome":false,"dates":["2018-09-21","2017-05-22","2018-02-02","2016-11-25"]}},{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end