# Deoptimized version of homework task

require 'json'
# require 'pry'
# require 'date'
require 'minitest/autorun'


def work
  puts 'Start work 2'

  # GC.disable
  # file_lines = File.read('data.txt').split("\n")
  file_lines = File.new('data.txt')
  # file_lines = File.new('data_small.txt')#.split("\n")
  # file_lines = File.new('data_large.txt')#.split("\n")
  # file_lines = File.new('data300k.txt')#.split("\n")

  # File.write('result.json', '')
  result_txt = File.new('result.json', 'a')

  browsers_all = []

  cnt_users = 0
  cnt_total_sessions = 0
  # result_txt = ''
  result_txt << '{"usersStats":{'
  first_user = true

  dates = []
  times = []
  browsers = []
  used_ie = 'true'
  always_used_chrome = 'true'

  begin
    loop do
      cols = file_lines.readline.strip.split(',')

      if cols[0] == 'user'
        if !first_user
          dates_user = dates.sort.reverse.to_s
          total_time_user = times.sum.to_s + ' min.'
          longest_session = times.max.to_s + ' min.'
          sessions_count = times.count
          browsers_user = browsers.sort.join(', ')

          result_txt << '{'
          result_txt << "\"sessionsCount\":#{sessions_count},"
          result_txt << "\"totalTime\":\"#{total_time_user}\","
          result_txt << "\"longestSession\":\"#{longest_session}\","
          result_txt << "\"browsers\":\"#{browsers_user}\","
          result_txt << "\"usedIE\":#{used_ie},"
          result_txt << "\"alwaysUsedChrome\":#{always_used_chrome},"
          result_txt << "\"dates\":#{dates_user}"
          result_txt << '},"'

          #новый пользователь
          result_txt << cols[2] + ' ' + cols[3] + '":'
          used_ie = 'false'
          always_used_chrome = 'true'
        else
          result_txt << '"' + cols[2] + ' ' + cols[3] + '":'
        end
        first_user = false

        dates = []
        times = []
        browsers = []
        cnt_users += 1
      end
      if cols[0] == 'session'
        browser_current = cols[3].upcase

        dates << cols[5]
        times << cols[4].to_i
        browsers << browser_current
        cnt_total_sessions += 1

        browsers_all << browser_current
        used_ie = 'true' if browser_current =~ /INTERNET EXPLORER/
        always_used_chrome = 'false' unless browser_current =~ /CHROME/
      end
    end
  rescue EOFError

    dates_user = dates.sort.reverse.to_s
    total_time_user =  times.sum.to_s + ' min.'
    longest_session = times.max.to_s + ' min.'
    sessions_count = times.count
    browsers_user = browsers.sort.join(', ')

    result_txt << '{'
    result_txt << "\"sessionsCount\":#{sessions_count},"
    result_txt << "\"totalTime\":\"#{total_time_user}\","
    result_txt << "\"longestSession\":\"#{longest_session}\","
    result_txt << "\"browsers\":\"#{browsers_user}\","
    result_txt << "\"usedIE\":#{used_ie},"
    result_txt << "\"alwaysUsedChrome\":#{always_used_chrome},"
    result_txt << "\"dates\":#{dates_user}"
    result_txt << '}},'

    unique_browsers_count = browsers_all.uniq.count
    all_browsers = browsers_all.uniq.sort.join(',')

    result_txt << "\"totalUsers\":#{cnt_users},"
    result_txt << "\"uniqueBrowsersCount\":#{unique_browsers_count},"
    result_txt << "\"totalSessions\":#{cnt_total_sessions},"
    result_txt << "\"allBrowsers\":\"#{all_browsers}\""

    result_txt << '}'
  end

  puts 'Finish work 2'
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
