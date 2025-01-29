# frozen_string_literal: true

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

def work(file = 'data80000.txt', disable_gc: false)
  GC.disable if disable_gc

  report = initial_report
  prepare_result_json
  user = nil
  @user_data = nil

  File.foreach(file) do |line|
    if line.start_with?('user')
      write_user_data(report, user) if @user_data
      user = parse_user(line)
      report['totalUsers'] += 1
      @user_data = nil
    else
      session = parse_session(line)
      prepare_data_for_first_session(user) unless @user_data
      report['totalSessions'] += 1
      unless report['allBrowsers'].include?(session['browser'])
        report['uniqueBrowsersCount'] += 1
        report['allBrowsers'] << session['browser']
      end
      @user_data['sessionsCount'] += 1
      @user_data['totalTime'] += session['time'].to_i
      @user_data['longestSession'] = session['time'].to_i if @user_data['longestSession'] < session['time'].to_i
      @user_data['browsers'] << session['browser'].upcase
      @user_data['usedIE'] = true if session['browser'].match?(/INTERNET EXPLORER/i)
      @user_data['alwaysUsedChrome'] = false unless session['browser'].match?(/CHROME/i)
      @user_data['dates'] << session['date']
    end
  end
  prepare_data_for_first_session(user) unless @user_data
  write_user_data(report, user, '')

  report['allBrowsers'] = report['allBrowsers'].sort.map(&:upcase).join(',')

  File.open('result.json', 'a') { |f| f.write "},#{report.to_json[1..]}" }
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def initial_report
  { 'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => [] }
end

def prepare_result_json
  File.open('result.json', 'a') { |f| f.write '{ "usersStats": {' }
end

def prepare_data_for_first_session(user)
  @user_data = {}
  @user_data['sessionsCount'] = 0
  @user_data['totalTime'] = 0
  @user_data['longestSession'] = 0
  @user_data['browsers'] = []
  @user_data['usedIE'] = false
  @user_data['alwaysUsedChrome'] = true
  @user_data['dates'] = []
end

def write_user_data(report, user, symbol = ',')
  @user_data['browsers'] = @user_data['browsers'].sort.join(', ')
  @user_data['dates'] = @user_data['dates'].sort.reverse
  @user_data['totalTime'] = "#{@user_data['totalTime']} min."
  @user_data['longestSession'] = "#{@user_data['longestSession']} min."

  File.open('result.json', 'a') { |f| f.write %("#{user}": #{@user_data.to_json}#{symbol}) }
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

a = Time.now
work
b = Time.now
p b - a
