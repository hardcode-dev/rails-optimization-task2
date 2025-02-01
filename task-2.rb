# Deoptimized version of homework task

require 'json'
require 'pry'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(cols)
  _, id, first_name, last_name, age = cols.split(',')
  {
    'id' => id,
    'first_name' => first_name,
    'last_name' => last_name,
    'age' => age,
  }
end

def parse_session(cols)
  _, user_id, session_id, browser, time, date = cols.split(',')
  {
    'user_id' => user_id,
    'session_id' => session_id,
    'browser' => browser,
    'time' => time,
    'date' => date,
  }
end

def write_user_to_json(file, user, first_user: false)
  # cached_dates = {}

  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

  times = user.sessions.map { |s| s['time'].to_i }
  browsers = user.sessions.map { |s| s['browser'].upcase }

  dates = user.sessions.map { |s| s['date'] }

  File.open file, "a" do |f|
    f.write ',' unless first_user
    str = <<-JSON
      \"#{user_key}\": {
          \"sessionsCount\": #{user.sessions.count},
          \"totalTime\": "#{times.sum.to_s} min.",
          \"longestSession\": "#{times.max.to_s} min.",
          \"browsers\": "#{browsers.sort.join(', ')}",
          \"usedIE\": #{browsers.any? { |b| b =~ /INTERNET EXPLORER/ }},
          \"alwaysUsedChrome\": #{browsers.all? { |b| b =~ /CHROME/ }},
          \"dates\": #{dates.sort.reverse}
        }
    JSON

    f.write str
  end

end

def work(filename = 'data.txt', gc: true, result: 'result.json')
  GC.disable unless gc

  report = {}

  current_user = nil
  uniqueBrowsers = Set.new
  totalSessions = 0
  user_object = nil
  totalUsers = 0
  # to see if we need a comma
  first_user = true

  File.open(result, 'a') { |file| file.write("{ \"usersStats\":{") }

  File.readlines(filename, chomp: true).each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      # write previous user
      if current_user
        write_user_to_json(result, current_user, first_user: first_user)
        first_user = false
      end
      parsed_user = parse_user(line)
      current_user = User.new(attributes: parsed_user, sessions: [])
      totalUsers += 1
    elsif cols[0] == 'session'
      session = parse_session(line)
      current_user.sessions.push session

      totalSessions += 1
      uniqueBrowsers.add(session['browser'].upcase)
    end
  end

  write_user_to_json(result, current_user, first_user: false)

  File.open(result, 'a') { |file| file.write("},") }

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

  # Подсчёт количества уникальных браузеров

  File.open result, "a" do |f|
    f.write "\"uniqueBrowsersCount\": #{uniqueBrowsers.count},"
    f.write "\"totalSessions\": #{totalSessions},"
    f.write "\"allBrowsers\": \"#{uniqueBrowsers.sort.join(',')}\","
    f.write "\"totalUsers\": #{totalUsers}"
    f.write("}")
  end
end

time = Time.now

work('data_large.txt', gc: true)

after = Time.now

p after - time

puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

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
    res = JSON.parse(File.read('result.json'))
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
