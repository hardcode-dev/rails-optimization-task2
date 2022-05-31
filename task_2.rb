# frozen_string_literal: true

# Optimized version of homework task

require 'json'
require 'pry'
require 'set'
require 'minitest/autorun'

DELIMITER = ','
WITH_SPACE = ', '
IE = 'I'
CR = 'C'

def work(path)
  file = File.open(path)
  @report_file = File.open('result.json', 'w')
  @report_file.write('{"usersStats":{')
  @user_report = {}
  @users_count = 0
  @sessions_count = 0
  @all_browsers = SortedSet.new

  file.each_line(chomp: true) do |line|
    cols = line.split(DELIMITER)
    if line.start_with?('u')
      @users_count += 1
      write_user_report(false) unless @user_report == {}
      @user_name = "#{cols[2]} #{cols[3]}"
      @user_report = {}
      @user_report[@user_name] = initialize_user_report
    elsif line.start_with?('s')
      @sessions_count += 1
      @user_report[@user_name]['sessionsCount'] += 1
      @user_report[@user_name]['totalTime'] += cols[4].to_i
      @user_report[@user_name]['longestSession'] = longest_session(cols[4].to_i)
      @user_report[@user_name]['browsers'] << cols[3].upcase!
      @user_report[@user_name]['usedIE'] = true if used_ie?(cols[3])
      @user_report[@user_name]['alwaysUsedChrome'] = only_chrome?(@user_report[@user_name]['browsers'])
      @user_report[@user_name]['dates'] << cols[5]
      @all_browsers << cols[3]
    end
  end
  write_user_report(true)
  @report_file.write(DELIMITER, summary_report.to_json[1..-1])
  @report_file.close

  puts 'MEMORY USAGE: %d MB' % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def longest_session(time)
  @user_report[@user_name]['longestSession'] < time ? time : @user_report[@user_name]['longestSession']
end

def used_ie?(browser)
  browser.start_with?(IE)
end

def only_chrome?(browsers)
  return false if @user_report[@user_name]['usedIE']

  browsers.all? { |b| b.start_with?(CR) }
end

def initialize_user_report
  {
    'sessionsCount' => 0,
    'totalTime' => 0,
    'longestSession' => 0,
    'browsers' => [],
    'usedIE' => false,
    'alwaysUsedChrome' => false,
    'dates' => []
  }
end

def write_user_report(last)
  prepare_report
  if last
    @report_file.write(@user_report.to_json[1..-2], '}')
  else
    @report_file.write(@user_report.to_json[1..-2], DELIMITER)
  end
end

def summary_report
  {
    'totalUsers' => @users_count,
    'uniqueBrowsersCount' => @all_browsers.size,
    'totalSessions' => @sessions_count,
    'allBrowsers' => @all_browsers.to_a.join(DELIMITER)
  }
end

def prepare_report
  @user_report[@user_name]['totalTime'] = "#{@user_report[@user_name]['totalTime']} min."
  @user_report[@user_name]['longestSession'] = "#{@user_report[@user_name]['longestSession']} min."
  @user_report[@user_name]['browsers'] = @user_report[@user_name]['browsers'].sort!.join(WITH_SPACE)
  @user_report[@user_name]['dates'] = @user_report[@user_name]['dates'].sort!.reverse!
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
