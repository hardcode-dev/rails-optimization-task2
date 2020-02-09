# Deoptimized version of homework task

require 'json'
require 'pry'
require 'oj'
# require 'minitest/autorun'

def user_line?
  @line_split[0] == 'user'
end

def session_line?
  @line_split[0] == 'session'
end

def browser
  @line_split[3]
end

def save_user_sessions(user_sessions)
  return if user_sessions.empty?

  user_stat = {}

  user_stat['sessionsCount'] = user_sessions.size
  times = user_sessions.map { |s| s[4].to_i }
  user_stat['totalTime'] = "#{times.sum} min."
  user_stat['longestSession'] = "#{times.max} min."

  user_browsers = user_sessions.map { |s| s[3] }
  user_browsers_uniq = user_browsers.uniq
  user_stat['browsers'] = user_browsers.sort.join(', ').upcase!
  user_stat['usedIE'] = !!user_browsers_uniq.find { |b| b =~ /Internet Explorer/ }
  user_stat['alwaysUsedChrome'] = user_browsers_uniq.all? { |b| b.upcase! =~ /Chrome/ }

  user_stat['dates'] = user_sessions.map { |s| s[5][0..9] }.sort!.reverse!

  user_stat
end

def work(filename = 'data.txt', disable_gc: false)
  start_time = Time.now

  # puts 'Start work'
  GC.disable if disable_gc

  total_users = 0
  total_sessions = 0
  unique_browsers = []
  user_sessions = []
  user_name = nil

  File.write('result.json', '')
  report_file = File.open('result.json', "a")
  report_file.puts '{'
  report_file.puts '"usersStats":{'

  IO.foreach(filename) do |line|
    @line_split = line.split(',')

    if user_line?
      total_users += 1

      unless user_name.nil?
        json = Oj.dump(save_user_sessions(user_sessions))
        report_file.puts "\"#{user_name}\": #{json},"
      end

      user_name = "#{@line_split[2]} #{@line_split[3]}"
      user_sessions = []
    end

    if session_line?
      total_sessions += 1
      unique_browsers << browser unless unique_browsers.include?(browser)
      user_sessions << @line_split
    end
  end

  json = Oj.dump(save_user_sessions(user_sessions))
  report_file.puts "\"#{user_name}\": #{json}"

  report_file.puts '},'

  # total stats
  report = {}
  report['totalUsers'] = total_users
  report['uniqueBrowsersCount'] = unique_browsers.count
  report['totalSessions'] = total_sessions
  report['allBrowsers'] = unique_browsers.sort.join(',').upcase

  json = Oj.dump(report)
  json[0] = '' # remove first {

  report_file.puts json
  report_file.close

  puts "#{Time.now - start_time} sec"
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

work

# Отчёт в json
#   - Сколько всего юзеров +
#   - Сколько всего уникальных браузеров +
#   - Сколько всего сессий +
#   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
#
#   - По каждому пользователю
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +


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
#     work
#     expected_result = '{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
#     assert_equal expected_result, File.read('result.json')
#   end
# end
