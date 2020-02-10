require 'byebug'
require 'minitest/autorun'
require 'oj'
require 'json'

def work(file_name = 'data.txt')
  if File.exist?(file_name)
    lines_count = `wc -l < "#{file_name}"`.to_i
  else
    puts "Input file should be of text type."
    exit
  end

  # create empty file (recreate in case it did exist) for report
  File.write('result.json', '')
  # start writing to report file
  start_report

  total_users = 0
  total_sessions = 0
  unique_browsers = {}
  user_name = ''
  user_stats = {}

  File.open(file_name, 'r') do |file|
    (0...lines_count).each do |line_number|
      line = file.gets
      fields = line.split(',')

      case fields[0]
      when 'user'
        # unless this is the first user
        unless user_name.empty?
          prepare_user_stats(user_stats)
          update_report(user_name, user_stats)
        end

        user_name = "#{fields[2]} #{fields[3]}"

        user_stats = {
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: false,
          dates: []
        }

        total_users += 1
      when 'session'
        session_time = fields[4].to_i

        user_stats[:sessionsCount] += 1
        user_stats[:totalTime] += session_time
        user_stats[:longestSession] = session_time if user_stats[:longestSession] < session_time
        user_stats[:browsers] << fields[3].upcase!
        user_stats[:dates] << fields[5].chomp!

        total_sessions += 1
        unique_browsers[fields[3]] = nil
      end
    end
  end

  # for the last user
  prepare_user_stats(user_stats)
  update_report(user_name, user_stats, last_user = true)

  # prepare the remaining data
  unique_browsers_count = unique_browsers.keys.size
  all_browsers = unique_browsers.keys.sort!.join(',')

  # finish writing report to file
  finish_report(total_users, total_sessions, all_browsers, unique_browsers_count)
end

def prepare_user_stats(user_stats)
  user_stats[:totalTime] = "#{user_stats[:totalTime]} min."
  user_stats[:longestSession] = "#{user_stats[:longestSession]} min."
  user_stats[:usedIE] = include_ie?(user_stats[:browsers])
  user_stats[:alwaysUsedChrome] = user_stats[:usedIE] ? false : all_chrome?(user_stats[:browsers])
  user_stats[:browsers] = user_stats[:browsers].sort!.join(', ')
  user_stats[:dates].sort!.reverse!
end

def include_ie?(browsers)
  browsers.each { |b| return true if b =~ /INTERNET EXPLORER/ }
  return false
end

def all_chrome?(browsers)
  browsers.each { |b| return false unless b =~ /CHROME/ }
  return true
end

def start_report
  write_to_report('{"usersStats":{')
end

def update_report(user_name, user_stats, last_user = false)
  write_to_report("\"#{user_name}\":#{Oj.dump(user_stats, mode: :compat)}")
  last_user ? write_to_report('},') : write_to_report(',')
end

def finish_report(total_users, total_sessions, all_browsers, unique_browsers_count)
  write_to_report(
    "\"totalUsers\":#{total_users},\"totalSessions\":#{total_sessions},\"allBrowsers\":\"#{all_browsers}\",\"uniqueBrowsersCount\":#{unique_browsers_count}}\n"
  )
end

def write_to_report(data)
  File.open('result.json', 'a') { |f| f.write(data) }
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
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n")
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
