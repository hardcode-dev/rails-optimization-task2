# Deoptimized version of homework task

require 'json'
require 'pry'
require 'set'
require 'minitest/autorun'

def work(path, disable_gc: true)
  GC.disable if disable_gc
  file = File.open(path)
  @report_file = File.new('result.json', 'w')
  @report = {
    'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => Set.new,
    'usersStats' => {}
  }

  file.each_line(chomp: true) do |line|
    cols = line.split(',')
    if line.start_with?('u')
      @report['totalUsers'] += 1
      @user_name = "#{cols[2]} #{cols[3]}"
      @report['usersStats'][@user_name] = {
        'sessionsCount' => 0,
        'totalTime' => 0,
        'longestSession' => 0,
        'browsers' => [],
        'usedIE' => false,
        'alwaysUsedChrome' => false,
        'dates' => []
      }
    elsif line.start_with?('s')
      @report['totalSessions'] += 1
      user_report = @report['usersStats'][@user_name]
      user_report['sessionsCount'] += 1
      user_report['totalTime'] += cols[4].to_i
      user_report['longestSession'] = cols[4].to_i if user_report['longestSession'] < cols[4].to_i
      user_report['browsers'] << cols[3].upcase
      user_report['usedIE'] = true if cols[3].start_with?('I')
      user_report['dates'] << cols[5]
      @report['allBrowsers'] << cols[3].upcase
    end
  end
  @report['uniqueBrowsersCount'] = @report['allBrowsers'].size
  @report['allBrowsers'] = @report['allBrowsers'].to_a.sort!.join(',')
  @report['usersStats'].each_value do |v|
    v['totalTime'] = "#{v['totalTime']} min."
    v['longestSession'] = "#{v['longestSession']} min."
    v['alwaysUsedChrome'] = true if v['browsers'].all? { |browser| browser.start_with?('C') }
    v['browsers'] = v['browsers'].sort!.join(', ')
    v['dates'] = v['dates'].sort!.reverse!
  end
  @report_file.write("#{@report.to_json}\n")
  @report_file.close

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

  puts 'MEMORY USAGE: %d MB' % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  GC.enable if disable_gc
end

# def collect_report(report, user)
#   report['usersStats'].merge!(report_for_user(user))
# end
#
# def report_for_user(user)
#   {
#     user[:name] => {
#       # Собираем количество сессий по пользователям
#       'sessionsCount' => sessions_count(user),
#       # Собираем количество времени по пользователям
#       'totalTime' => total_time(user),
#       # Выбираем самую длинную сессию пользователя
#       'longestSession' => longest_session(user),
#       # Браузеры пользователя через запятую
#       'browsers' => user_browsers(user),
#       # Хоть раз использовал IE?
#       'usedIE' => used_ie?(user),
#       # Всегда использовал только Chrome?
#       'alwaysUsedChrome' => always_used_chrome?(user),
#       # Даты сессий через запятую в обратном порядке в формате iso8601
#       'dates' => user_sessions_dates(user)
#     }
#   }
# end
#
# def generate_sessions_report(report, users, sessions, browsers)
#   report['totalUsers'] = users
#   report['uniqueBrowsersCount'] = browsers.count
#   report['totalSessions'] = sessions
#   report['allBrowsers'] = browsers.map!(&:upcase).sort.join(',')
# end
#
# def sessions_count(user)
#   user[:sessions].count
# end
#
# def total_time(user)
#   "#{user[:sessions].map { |s| s['time'].to_i }.sum} min."
# end
#
# def longest_session(user)
#   "#{user[:sessions].map { |s| s['time'].to_i }.max} min."
# end
#
# def user_browsers(user)
#   user[:sessions].map { |s| s['browser'].upcase }.sort.join(', ')
# end
#
# def used_ie?(user)
#   user[:sessions].map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
# end
#
# def always_used_chrome?(user)
#   user[:sessions].map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ }
# end
#
# def user_sessions_dates(user)
#   user[:sessions].map { |s| s['date'] }.sort.reverse
# end

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
    work(path = 'data.txt')
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
