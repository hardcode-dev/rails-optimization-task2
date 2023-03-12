# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'debug'

def parse_user(user)
  fields = user.split(',')
  "#{fields[2]} #{fields[3]}"
end

def parse_session(session)
  fields = session.chomp.split(',')
  { 'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5] }
end

def work(file = 'data.txt')
  report = {}
  report['totalUsers'] = 0
  report['uniqueBrowsersCount'] = 0
  report['totalSessions'] = 0
  report['allBrowsers'] = []
  report['usersStats'] = {}

  user = nil
  first_session = true
  File.foreach(file) do |line|
    if line.start_with?('user')
      update_data_for_user(report, user) if user
      user = parse_user(line)
      report['totalUsers'] += 1
      first_session = true
    else
      session = parse_session(line)
      prepare_data_for_first_session(report, user) if first_session
      report['totalSessions'] += 1
      unless report['allBrowsers'].include?(session['browser'])
        report['uniqueBrowsersCount'] += 1
        report['allBrowsers'] << session['browser']
      end
      report['usersStats'][user]['sessionsCount'] += 1
      report['usersStats'][user]['totalTime'] += session['time'].to_i
      report['usersStats'][user]['longestSession'] = session['time'].to_i if report['usersStats'][user]['longestSession'] < session['time'].to_i
      report['usersStats'][user]['browsers'] << session['browser'].upcase
      report['usersStats'][user]['usedIE'] = true if session['browser'].match?(/INTERNET EXPLORER/i)
      report['usersStats'][user]['alwaysUsedChrome'] = false unless session['browser'].match?(/CHROME/i)
      report['usersStats'][user]['dates'] << session['date']

      first_session = false
    end
  end
  prepare_data_for_first_session(report, user) if first_session
  update_data_for_user(report, user) if user

  report['allBrowsers'] = report['allBrowsers'].sort.map(&:upcase).join(',')

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def prepare_data_for_first_session(report, user)
  report['usersStats'][user] = {}
  report['usersStats'][user]['sessionsCount'] = 0
  report['usersStats'][user]['totalTime'] = 0
  report['usersStats'][user]['longestSession'] = 0
  report['usersStats'][user]['browsers'] = []
  report['usersStats'][user]['usedIE'] = false
  report['usersStats'][user]['dates'] = []
end

def update_data_for_user(report, user)
  report['usersStats'][user]['browsers'] = report['usersStats'][user]['browsers'].sort.join(', ')
  report['usersStats'][user]['dates'] = report['usersStats'][user]['dates'].sort.reverse
  report['usersStats'][user]['totalTime'] = "#{report['usersStats'][user]['totalTime']} min."
  report['usersStats'][user]['longestSession'] = "#{report['usersStats'][user]['longestSession']} min."
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

a = Time.now
work('data80000.txt')
b = Time.now
p b - a
pp GC.stat

