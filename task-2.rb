# frozen_string_literal: true

require 'date'
require 'set'
LAST_SESSION_COLUMN = 5
USER_COLUMNS = {
  1 => :id, 2 => :first_name, 3 => :last_name, 4 => :age
}.freeze

SESSION_COLUMNS = {
  1 => :user_id, 2 => :session_id, 3 => :browser, 4 => :time, 5 => :date
}.freeze

def fetch_user_and_sessions(filename)
  user = { sessions: [] }
  session = {}
  column_number = 0
  File.foreach(ENV['DATA_FILE'] || filename || 'data.txt', chomp: true) do |line|
    column_number = 0

    line.split(',') do |column_value|
      if column_value == 'user'
        yield user if user[:id]

        user = { sessions: [] }

        @currently_user = true
        @currently_session = false
      elsif column_value == 'session'
        session = {}

        @currently_session = true
        @currently_user = false
      elsif column_number == LAST_SESSION_COLUMN
        session[SESSION_COLUMNS[column_number]] = column_value
        user[:sessions] << session
      elsif @currently_user
        user[USER_COLUMNS[column_number]] = column_value
      elsif @currently_session
        session[SESSION_COLUMNS[column_number]] = column_value
      end

      column_number += 1
    end
  end

  # последний аккумулированный юзер: обхожу так, т.к. при построчной обработке нет простого способа узнать о конце файла
  yield user, true
end

def work(filename: nil, disable_gc: false)
  GC.disable if disable_gc

  @report = File.open('result.json', 'w')
  @total_browsers = Set.new
  @report.write '{"usersStats":{'
  total = { totalUsers: 0, totalSessions: 0 }

  fetch_user_and_sessions(filename) do |user, last_user|
    total[:totalUsers] += 1

    session_count = user[:sessions].size
    total[:totalSessions] += session_count
    session_browsers = []
    session_times = []
    session_dates = []
    used_ie = false
    always_used_chrome = true

    user[:sessions].each do |session|
      browser = session[:browser].upcase!
      used_ie = true if browser.include?('INTERNET EXPLORER')
      always_used_chrome = false unless browser.include?('CHROME')
      session_browsers << browser
      @total_browsers << browser
      session_times << session[:time].to_i
      session_dates << session[:date]
    end

    @report.write <<~TEXT
      "#{user[:first_name]} #{user[:last_name]}": {
        "sessionsCount": #{session_count},
        "totalTime": "#{session_times.sum} min.",
        "longestSession": "#{session_times.max} min.",
        "browsers": "#{session_browsers.sort!.join(', ')}",
        "usedIE": #{used_ie},
        "alwaysUsedChrome": #{always_used_chrome},
        "dates": #{session_dates.sort!.reverse!}
      }#{last_user ? nil : ','}
    TEXT
  end

  @total_browsers = @total_browsers.sort

  total[:uniqueBrowsersCount] = @total_browsers.size
  total[:allBrowsers] = @total_browsers.join(',')
  @report.write <<~TEXT
    },
      "uniqueBrowsersCount": #{total[:uniqueBrowsersCount]},
      "allBrowsers": "#{total[:allBrowsers]}",
      "totalUsers": #{total[:totalUsers]},
      "totalSessions": #{total[:totalSessions]}
    }
  TEXT

  { used_memory: `ps -o rss= -p #{Process.pid}`.to_i / 1024 }
ensure
  @report.close
end

return unless ENV['TEST_ON']

require 'json'
require 'minitest/autorun'
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
