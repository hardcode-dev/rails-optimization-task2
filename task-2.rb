# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'age' => user[4]
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3].upcase,
    'time' => session[4].to_i,
    'date' => session[5],
  }
end

def collect_stats_from(user_sessions)
  user_data = { time: [], browsers: [], dates: [] }

  user_sessions.each do |session|
    user_data[:time] << session['time']
    user_data[:browsers] << session['browser']
    user_data[:dates] << session['date']
  end

  {
    'sessionsCount' => user_sessions.count,
    'totalTime' => "#{user_data[:time].sum} min.",
    'longestSession' => "#{user_data[:time].max} min.",
    'browsers' => user_data[:browsers].sort.join(', '),
    'usedIE' => user_data[:browsers].any? { |b| b.match?(/INTERNET EXPLORER/) },
    'alwaysUsedChrome' => user_data[:browsers].all? { |b| b.match?(/CHROME/) },
    'dates' => user_data[:dates].sort.reverse
  }
end

def work(filename, disable_gc: false)
  GC.disable if disable_gc

  file = File.open('result.json', 'w+')
  file.write('{"usersStats":{')


  browsers = []
  user = nil
  total_users = 0
  total_sessions = 0
  user_sessions = []
  File.foreach(filename, chomp: true) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      if user
        file.write("\"#{user}\":#{collect_stats_from(user_sessions).to_json},")
      end

      total_users += 1
      user_sessions = []
      user = "#{cols[2]} #{cols[3]}"
    elsif cols[0] == 'session'
      sessoin = parse_session(cols)
      user_sessions << sessoin
      browsers << sessoin['browser']
      total_sessions += 1
    end
  end

  file.write("\"#{user}\":#{collect_stats_from(user_sessions).to_json}},")

  unique_browsers = browsers.uniq.sort
  report = {
    'totalUsers': total_users,
    'uniqueBrowsersCount': unique_browsers.count,
    'totalSessions': total_sessions,
    'allBrowsers': unique_browsers.join(',')
  }

  data = report.to_json
  data.slice!(0)
  file.write(data)
  file.close
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
    work('data.txt')
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
