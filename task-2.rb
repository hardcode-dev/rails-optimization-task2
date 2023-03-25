# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'set'
require 'oj'

require 'memory_profiler'
require 'ruby-prof'

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def stats_for_user(sessions)
  times = sessions.map { |s| s['time'] }
  browsers = sessions.map { |s| s['browser'] }.sort!

  {
    'sessionsCount' => sessions.count,
    'totalTime' => "#{times.sum} min.",
    'longestSession' => "#{times.max} min.",
    'browsers' => browsers.join(', '),
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    'dates' => sessions.map { |s| s['date'] }.sort!.reverse!
  }
end

def work(file)
  uniqueBrowsers = Set.new
  totalSessions = 0
  totalUsers = 0

  user_key = nil
  user_sessions = nil

  result_file = File.open('result.json', 'a')

  writer = Oj::StreamWriter.new(result_file)
  writer.push_object
  writer.push_key('usersStats')
  writer.push_object

  IO.foreach(file, chomp: true) do |line|
    fields = line.split(',')

    if fields[0] == 'user'
      writer.push_value(stats_for_user(user_sessions), user_key) unless user_key.nil?

      user_key = "#{fields[2]} #{fields[3]}"
      user_sessions = []
      totalUsers += 1
    else
      session = parse_session(fields)
      user_sessions << session
      uniqueBrowsers << session['browser']
      totalSessions += 1
    end
  end
  writer.push_value(stats_for_user(user_sessions), user_key)
  writer.pop

  writer.push_value(totalUsers, 'totalUsers')
  writer.push_value(uniqueBrowsers.count, 'uniqueBrowsersCount')
  writer.push_value(totalSessions, 'totalSessions')
  writer.push_value(uniqueBrowsers.sort.join(','), 'allBrowsers')
  writer.pop

  result_file.close

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

  def test_expect_result
    work("data.txt")

    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end

  def test_report
    result = RubyProf.profile(measure_mode: RubyProf::MEMORY) do
      work("data_80k.txt")
    end

    printer = RubyProf::GraphPrinter.new(result)
    printer.print(STDOUT, {})
  end
end
