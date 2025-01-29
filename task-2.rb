# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

require 'ruby-prof'
require 'set'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_session(cols)
  {
    'user_id' => cols[1],
    'session_id' => cols[2],
    'browser' => cols[3],
    'time' => cols[4],
    'date' => cols[5],
  }
end

def add_session_to_file!(report_file, username, sessions, last_record: false)
  sessions_time = sessions.inject(0) { |total, session| total += session['time'].to_i }
  longest_session = sessions.map { |session| session['time'].to_i }.max
  browsers = sessions.map { |session| session['browser'].upcase.freeze }.sort!
  res = {
    username => {
      'sessionsCount' => sessions.count,
      'totalTime' => "#{sessions_time} min.",
      'longestSession' => "#{longest_session} min.",
      'browsers' => browsers.join(', '),
      'usedIE' => browsers.any? { |browser| browser[/INTERNET EXPLORER/] },
      'alwaysUsedChrome' => browsers.all? { |browser| browser[/CHROME/]},
      'dates' => sessions.map { |session| session['date'].strip }.sort! { |a, b| b <=> a}
    }
  }.to_json

  last_record ? report_file.write("#{res[1..-2]}") : report_file.write("#{res[1..-2]},")
end

def work(file = 'data.txt', lines = nil)
  # init report data
  report = {}
  report[:totalUsers] = 0
  report[:totalSessions] = 0
  uniqueBrowsers = Set.new
  sessions_accumulator = []
  current_user = nil
  i = 0
  divider = ','.freeze

  # init result file
  File.open('result.json', 'w') { |f| f.write('') }
  result_file = File.open('result.json', 'a')
  result_file.write('{"usersStats":{')

  File.foreach(file) do |line|
    cols = line.split(divider)

    if cols[0] == 'user' && sessions_accumulator.any?
      add_session_to_file!(result_file, current_user, sessions_accumulator)
      sessions_accumulator = []

      current_user = "#{cols[2]} #{cols[3]}".freeze
      report[:totalUsers] += 1
    elsif cols[0] == 'user'.freeze
      current_user = "#{cols[2]} #{cols[3]}".freeze
      report[:totalUsers] += 1
    elsif cols[0] == 'session' && current_user
      session = parse_session(cols)
      sessions_accumulator << session
      uniqueBrowsers << session['browser']
      report[:totalSessions] += 1
    end
    i += 1
    break if lines && i > lines
  end

  # write last user's data
  add_session_to_file!(result_file, current_user, sessions_accumulator, last_record: true)
  result_file.write("},")

  # add summary information to report
  report[:uniqueBrowsersCount] = uniqueBrowsers.count
  report[:allBrowsers] = uniqueBrowsers.to_a.map! { |browser| browser.upcase }.sort!.join(',')
  result_file.write("#{report.to_json}"[1..-2])

  # close opened json
  result_file.write("}")
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

  def test_result
    work
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end

work('data_large.txt')