# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'set'
# require 'minitest/autorun'

def get_user_stats!(users_stats)
  users_stats[:longestSession] = "#{users_stats[:longestSession]} min."
  users_stats[:totalTime] = "#{users_stats[:totalTime]} min."
  users_stats[:browsers] = users_stats[:browsers].sort!.join(', ')
  users_stats[:dates] = users_stats[:dates].sort!.reverse!
end

def work(filepath = 'data_large.txt')
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: Set.new,
    totalSessions: 0,
    allBrowsers: Set.new,
  }

  users_stats = {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: true,
    dates: []
  }

  user_key = nil
  user_check = nil
  session_check = nil
  col = 0
  output = File.open('result.json', 'w')
  output.write('{"usersStats":{')

  File.foreach(filepath) do |line|
    line.split(',') do |item|
      col += 1
      if item == 'user'
        if session_check
          get_user_stats!(users_stats)
          output.write("\"#{user_key}\":#{users_stats.to_json},")
        end
        user_check = true
        session_check = false
        users_stats = {
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: true,
          dates: []
        }
        user_key = nil
        col = 0
        report[:totalUsers] += 1
        next
      end
      if item == 'session'
        user_check = false
        session_check = true
        col = 0
        report[:totalSessions] += 1
        users_stats[:sessionsCount] += 1
        next
      end

      if user_check
        case col
        when 2
          user_key = item
        when 3
          user_key = "#{user_key} #{item}"
        end
      end

      if session_check
        case col
        when 3
          report[:allBrowsers].add(item.upcase!)
          report[:uniqueBrowsersCount].add(item)
          users_stats[:browsers] << item
          users_stats[:usedIE] ||= item.match?(/INTERNET EXPLORER/)
          users_stats[:alwaysUsedChrome] &&= item.match?(/CHROME/)
        when 4
          users_stats[:totalTime] += item.to_i
          users_stats[:longestSession] = item.to_i if users_stats[:longestSession] < item.to_i
        when 5
          users_stats[:dates] << item
        end
      end
    end
  end

  report[:uniqueBrowsersCount] = report[:uniqueBrowsersCount].size
  report[:allBrowsers] = report[:allBrowsers].sort.join(',')

  get_user_stats!(users_stats)
  output.write("\"#{user_key}\":#{users_stats.to_json}},#{report.to_json[1..-1]}")
  output.close
end

# class TestMe < Minitest::Test
#   def setup
#     File.write('result.json', '')
#     File.write('data.txt',
# 'user,0,Leida,Cira,0
# session,0,0,Safari 29,87,2016-10-23
# session,0,1,Firefox 12,118,2017-02-27
# session,0,2,Internet Explorer 28,31,2017-03-28
# session,0,3,Internet Explorer 28,109,2016-09-15
# session,0,4,Safari 39,104,2017-09-27
# session,0,5,Internet Explorer 35,6,2016-09-01
# user,1,Palmer,Katrina,65
# session,1,0,Safari 17,12,2016-10-21
# session,1,1,Firefox 32,3,2016-12-20
# session,1,2,Chrome 6,59,2016-11-11
# session,1,3,Internet Explorer 10,28,2017-04-29
# session,1,4,Chrome 13,116,2016-12-28
# user,2,Gregory,Santos,86
# session,2,0,Chrome 35,6,2018-09-21
# session,2,1,Safari 49,85,2017-05-22
# session,2,2,Firefox 47,17,2018-02-02
# session,2,3,Chrome 20,84,2016-11-25
# ')
#   end

#   def test_result
#     work('data.txt')
#     expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
#     assert_equal expected_result, JSON.parse(File.read('result.json'))
#   end
# end
