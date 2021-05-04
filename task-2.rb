# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
# require 'minitest/autorun'

def parse_user(fields)
  parsed_result = {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5].chomp
  }
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
def work(filepath = 'data-10000.txt')
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: [],
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }
  user_key = nil

  File.foreach(filepath) do |col|
    cols = col.split(',')
    if cols[0] == 'user'
      user = parse_user(cols)
      user_key = "#{user[:first_name]}" + ' ' + "#{user[:last_name]}"
      report[:totalUsers] += 1
      report[:usersStats][user_key] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: true,
        dates: []
      }
    end
    next unless cols[0] == 'session'

    session = parse_session(col)
    report[:totalSessions] += 1
    report[:allBrowsers] << session[:browser]
    report[:uniqueBrowsersCount] << session[:browser]

    report[:usersStats][user_key][:sessionsCount] += 1
    report[:usersStats][user_key][:totalTime] += session[:time]
    report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], session[:time]].max
    report[:usersStats][user_key][:browsers] << session[:browser]
    report[:usersStats][user_key][:usedIE] ||= session[:browser].match?(/INTERNET EXPLORER/)
    report[:usersStats][user_key][:alwaysUsedChrome] &&= session[:browser].match?(/CHROME/)
    report[:usersStats][user_key][:dates] << session[:date]
  end

  report[:uniqueBrowsersCount] = report[:uniqueBrowsersCount].uniq.size
  report[:allBrowsers] = report[:allBrowsers].sort.uniq.join(',')

  report[:usersStats].each_value do |user_hash|
    user_hash[:longestSession] = "#{user_hash[:longestSession]} min."
    user_hash[:totalTime] = "#{user_hash[:totalTime]} min."
    user_hash[:browsers] = user_hash[:browsers].sort.join(', ')
    user_hash[:dates] = user_hash[:dates].sort!.reverse!
  end

  File.write('result.json', "#{report.to_json}\n")
end

# class TestMe < Minitest::Test
#   def setup
#     File.write('result.json', '')
#     File.write('data.txt',
# 'user,0,Leida,Cira,0
# session,0,0,Safari 29,87,2016-10-23
# session,0,1,Firefox 12,118,2017-02-27
# session,0,2,Internet Explorer 28,31,2017-03-28
# session,0,3,Internet Explorer 28,109,2016-09-15
# session,0,4,Safari 39,104,2017-09-27
# session,0,5,Internet Explorer 35,6,2016-09-01
# user,1,Palmer,Katrina,65
# session,1,0,Safari 17,12,2016-10-21
# session,1,1,Firefox 32,3,2016-12-20
# session,1,2,Chrome 6,59,2016-11-11
# session,1,3,Internet Explorer 10,28,2017-04-29
# session,1,4,Chrome 13,116,2016-12-28
# user,2,Gregory,Santos,86
# session,2,0,Chrome 35,6,2018-09-21
# session,2,1,Safari 49,85,2017-05-22
# session,2,2,Firefox 47,17,2018-02-02
# session,2,3,Chrome 20,84,2016-11-25
# ')
#   end

#   def test_result
#     work('data.txt')
#     expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
#     assert_equal expected_result, JSON.parse(File.read('result.json'))
#   end
# end
