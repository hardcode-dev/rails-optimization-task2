# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

def work(filename = 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  # open file instead of full read into memory
  file = File.open(filename)

  # create report template to update it later in each iteration
  report = {
    'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => [],
    'usersStats' => {}
  }
  # user object to collect sessions
  user = {
    'id' => nil,
    'name' => '',
    'sessions' => []
  }

  # stream the file line by line to keep memory usage under control
  file.each_line(chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      report['usersStats'][user['name']] = collect_stats_from_user(user) unless user['id'].nil?
      user['id'] = cols[1]
      user['name'] = "#{cols[2]} #{cols[3]}"
      user['sessions'] = []
      report['totalUsers'] += 1
    else
      report['totalSessions'] += 1
      unless report['allBrowsers'].include?(cols[3].upcase)
        report['allBrowsers'] << cols[3].upcase
        report['uniqueBrowsersCount'] += 1
      end
      user['sessions'] << {
        'browser' => cols[3].upcase,
        'time' => cols[4].to_i,
        'date' => cols[5]
      }
    end
  end
  # last stats for last user's sessions
  report['usersStats'][user['name']] = collect_stats_from_user(user)

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

  report['allBrowsers'] = report['allBrowsers'].sort.join(',')

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def collect_stats_from_user(user)
  { # Собираем количество сессий по пользователям
    'sessionsCount' => user['sessions'].count,
    # Собираем количество времени по пользователям
    'totalTime' => user['sessions'].map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
    # Выбираем самую длинную сессию пользователя
    'longestSession' => user['sessions'].map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
    # Браузеры пользователя через запятую
    'browsers' => user['sessions'].map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => user['sessions'].map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => user['sessions'].map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user['sessions'].map{|s| s['date']}.sort.reverse }
end

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
    work
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
