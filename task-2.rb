# Optimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'stackprof'
require 'ruby-prof'
require 'memory_profiler'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end

  def sessions_count
    @sessions_count ||= @sessions.size
  end

  def total_time
    @total_time ||= sessions_time.sum.to_s + ' min.'
  end

  def longest_session
    @longest_session ||= sessions_time.max.to_s + ' min.'
  end

  def browsers
    @browsers ||= upcase_browsers.sort.join(', ')
  end

  def used_ie?
    @used_ie ||= upcase_browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
  end

  def always_used_chrome?
    @always_used_chrome ||= upcase_browsers.all? { |b| b =~ /CHROME/ }
  end

  def dates
    @dates ||= @sessions.map { |s| s['date'].chomp }.sort!.reverse!
  end

  private

  def sessions_time
    @sessions_time ||= @sessions.map { |s| s['time'].to_i }
  end

  def upcase_browsers
    @upcase_browsers ||= @sessions.map { |s| s['browser'].upcase }
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def write_user_stat(file, user)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
  file.write('"' + user_key + '": ')
  json_item = {
    # Собираем количество сессий по пользователям
    'sessionsCount' => user.sessions_count,
    # Собираем количество времени по пользователям
    'totalTime' => user.total_time,
    # Выбираем самую длинную сессию пользователя
    'longestSession' => user.longest_session,
    # Браузеры пользователя через запятую
    'browsers' => user.browsers,
    # Хоть раз использовал IE?
    'usedIE' => user.used_ie?,
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => user.always_used_chrome?,
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => user.dates
  }.to_json
  file.write(json_item)
end

def work(filename = 'data.txt')
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
  report = {
    totalUsers: 0,
    totalSessions: 0
  }
  users = []
  sessions = []
  user_sessions = []
  uniqueBrowsers = Hash.new(0)
  current_user = nil
  prev_user = nil

  File.open('result.json', 'w') do |file|
    file.puts('{')
    file.puts('"usersStats": {')

    File.foreach(filename) do |line|
      cols = line.split(',')

      if cols[0] == 'user'
        report[:totalUsers] += 1
        user = parse_user(cols)

        prev_user = current_user
        current_user = user

        if prev_user != nil
          user = User.new(attributes: prev_user, sessions: user_sessions)
          write_user_stat(file, user)
          file.puts(",")
          user_sessions = []
        end

        users << user
      end

      if cols[0] == 'session'
        report[:totalSessions] += 1
        session = parse_session(cols)

        browser = session['browser']
        uniqueBrowsers[browser] += 1

        user_sessions << session
        sessions << session
      end
    end

    user = User.new(attributes: current_user, sessions: user_sessions)
    write_user_stat(file, user)
    file.puts("\n},")

    #################################################
    file.puts(%Q("totalUsers": #{report[:totalUsers]},))
    file.puts(%Q("uniqueBrowsersCount": #{uniqueBrowsers.keys.size},))
    file.puts(%Q("totalSessions": #{report[:totalSessions]},))
    allBrowsers = uniqueBrowsers.keys
                                .map { |b| b.upcase }
                                .sort
                                .uniq
                                .join(',')
    file.puts(%Q("allBrowsers": "#{allBrowsers}"))

    file.puts("}")
  end

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


# work('data.txt')
# work('data10000.txt')
# work('data40000.txt')
# work('data500000.txt')

### memory_profiler
# report = MemoryProfiler.report do
#   work('data10000.txt')
# end
# report.pretty_print(scale_bytes: true)

### stackprof
# StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
#   work('data10000.txt')
# end

### ruby-prof
# RubyProf.measure_mode = RubyProf::ALLOCATIONS
# На этот раз профилируем не allocations, а объём памяти!
# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#   work('data10000.txt')
# end
#
# printer = RubyProf::FlatPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))
#
# # printer = RubyProf::DotPrinter.new(result)
# # printer.print(File.open('ruby_prof_reports/graphviz.dot', 'w+'))
#
# printer = RubyProf::GraphHtmlPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
#
# printer = RubyProf::CallStackPrinter.new(result)
# printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
#
# # printer = RubyProf::CallTreePrinter.new(result)
# # printer.print(path: 'ruby_prof_reports', profile: 'profile')
