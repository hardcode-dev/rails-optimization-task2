# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

COMMA = ','.freeze
SPACE = ' '.freeze

class User
  attr_accessor :name, :sessions, :sessions_count, :total_time, :longest_session, :browsers, :dates, :always_chrome

  @@last = nil
  @@count = 0
  @@total_session_count = 0
  @@unique_browsers = []

  def initialize(name)
    @name = name
    @sessions_count = 0
    @total_time = 0
    @longest_session = 0
    @browsers = []
    @dates = []
    @always_chrome = true
    @@last = self
    @@count += 1
  end

  def add_session(session)

    @sessions_count += 1
    time = session[4].to_i
    @total_time += time
    current_longest_session = @longest_session 
    if @longest_session < time
      @longest_session = time
    end
    browser = session[3]
    @browsers << browser
    if !browser.include?('Chrome')
      @always_chrome = false
    end
    @dates << session[5]
  end

  def serialize(last = false)
    user_browsers = @browsers.map{|user_browser| user_browser.upcase}.sort.join(', ')
    @@total_session_count += @sessions_count
    @@unique_browsers = @@unique_browsers | @browsers.uniq
    File.open('result.json', "a") do |f| 
      f.puts "  \"#{@name}\": {\n"
      f.puts "    \"sessionsCount\": #{@sessions_count},\n"
      f.puts "    \"totalTime\": \"#{@total_time} min.\",\n"
      f.puts "    \"longestSession\": \"#{@longest_session} min.\",\n"
      f.puts "    \"browsers\": \"#{user_browsers}\",\n"
      f.puts "    \"usedIE\": #{user_browsers.include?('INTERNET EXPLORER')},\n"
      f.puts "    \"alwaysUsedChrome\": #{@always_chrome},\n"
      f.puts "    \"dates\": #{@dates.uniq.sort{|a,b| b <=> a }.to_json}\n"
      if last
        f.puts "  }\n"
        f.puts " },\n"
      else
        f.puts "  },\n"
      end
    end
    @@last = nil
  end

  def self.clean_up
    @@count = 0
    @@total_session_count = 0
    @@unique_browsers = []
  end
  
  def self.last
    @@last
  end

  def self.count
    @@count
  end

  def self.total_session_count 
    @@total_session_count
  end

  def self.unique_browsers
    @@unique_browsers
  end


end


def work

  File.write('result.json', "{\"usersStats\": {\n")

  File.readlines('small.txt').each do |line|
    cols = line.chomp.split(COMMA)
    if cols[0] == 'user'
      User.last&.serialize
      User.new("#{cols[2]} #{cols[3]}")
    elsif cols[0] == 'session'
      User.last.add_session(cols)
    end
  end

  User.last.serialize(true)

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


  File.open('result.json', "a") do |f| 
    f.puts "\"totalUsers\": #{User.count},\n"
    f.puts "\"uniqueBrowsersCount\": #{User.unique_browsers.count},\n"
    f.puts "\"totalSessions\": #{User.total_session_count},\n"
    f.puts "\"allBrowsers\": \"#{User.unique_browsers.sort.map(&:upcase).join(", ")}\"\n"

    f.puts "}\n"
    User.clean_up
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
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
    # expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    
    expected_result = JSON.parse('{"usersStats": {
      "Leida Cira": {
        "sessionsCount": 6,
        "totalTime": "455 min.",
        "longestSession": "118 min.",
        "browsers": "FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39",
        "usedIE": true,
        "alwaysUsedChrome": false,
        "dates": ["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]
      },
      "Palmer Katrina": {
        "sessionsCount": 5,
        "totalTime": "218 min.",
        "longestSession": "116 min.",
        "browsers": "CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17",
        "usedIE": true,
        "alwaysUsedChrome": false,
        "dates": ["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]
      },
      "Gregory Santos": {
        "sessionsCount": 4,
        "totalTime": "192 min.",
        "longestSession": "85 min.",
        "browsers": "CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49",
        "usedIE": false,
        "alwaysUsedChrome": false,
        "dates": ["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]
      }
     },
    "totalUsers": 3,
    "uniqueBrowsersCount": 14,
    "totalSessions": 15,
    "allBrowsers": "CHROME 13, CHROME 20, CHROME 35, CHROME 6, FIREFOX 12, FIREFOX 32, FIREFOX 47, INTERNET EXPLORER 10, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 17, SAFARI 29, SAFARI 39, SAFARI 49"
    }')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
