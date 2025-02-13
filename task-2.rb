# frozen_string_literal: true
# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'
require 'minitest/autorun'

def work(path = 'data.txt', output_path = 'result.json')
  total_users = 0
  total_sessions = 0
  unique_browsers = {}

  current_user = nil

  File.open(output_path, 'w') do |f|
    writer = Oj::StreamWriter.new(f)
    writer.push_object
    writer.push_key("usersStats")
    writer.push_object 

    flush_current_user = lambda do
      next unless current_user

      full_name = "#{current_user[:first_name]} #{current_user[:last_name]}".strip
      user_obj = {
        'sessionsCount' => current_user[:sessionsCount],
        'totalTime' => "#{current_user[:totalTime]} min.",
        'longestSession' => "#{current_user[:longestSession]} min.",
        'browsers' => current_user[:browsers].sort.join(', '),
        'usedIE' => current_user[:usedIE],
        'alwaysUsedChrome' => current_user[:alwaysUsedChrome],
        'dates' => current_user[:dates].sort.reverse
      }

      writer.push_key(full_name)
      writer.push_value(user_obj)
    end

    File.foreach(path) do |line|
      line.strip!
      next if line.empty?

      parts = line.split(',')
      case parts[0]
      when 'user'
        flush_current_user.call if current_user

        # user,ID,first_name,last_name,age
        total_users += 1
        user_id = parts[1]
        first_name = parts[2]
        last_name = parts[3]
        current_user = {
          id: user_id,
          first_name: first_name,
          last_name: last_name,
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: true,
          dates: []
        }
      when 'session'
        total_sessions += 1
        session_user_id = parts[1]

        if current_user.nil? || current_user[:id] != session_user_id
          flush_current_user.call if current_user
          # Empty user statistics
          current_user = {
            id: session_user_id,
            first_name: "",
            last_name: "",
            sessionsCount: 0,
            totalTime: 0,
            longestSession: 0,
            browsers: [],
            usedIE: false,
            alwaysUsedChrome: true,
            dates: []
          }
        end

        browser = parts[3].strip
        browser_up = browser.upcase
        unique_browsers[browser_up] = true
        time = parts[4].to_i
        date = parts[5].strip

        current_user[:sessionsCount] += 1
        current_user[:totalTime] += time
        current_user[:longestSession] = time if time > current_user[:longestSession]
        current_user[:browsers] << browser_up
        current_user[:dates] << date
        current_user[:usedIE] ||= browser_up.include?("INTERNET EXPLORER")
        current_user[:alwaysUsedChrome] &&= browser_up.include?("CHROME")
      end
    end

    flush_current_user.call if current_user
    writer.pop

    writer.push_key("totalUsers")
    writer.push_value(total_users)

    writer.push_key("totalSessions")
    writer.push_value(total_sessions)

    writer.push_key("uniqueBrowsersCount")
    writer.push_value(unique_browsers.keys.size)

    all_browsers = unique_browsers.keys.sort.join(',')

    writer.push_key("allBrowsers")
    writer.push_value(all_browsers)

    writer.pop
  end
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
