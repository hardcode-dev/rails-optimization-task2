# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'pry'
require 'csv'
require 'date'
require 'minitest/benchmark'
require 'minitest/autorun'
require 'benchmark'
require 'ruby-prof'
require 'stackprof'
require 'set'
require 'memory_profiler'

DATE_FORMAT = '%Y-%m-%d'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:)
    @attributes = {
      id: attributes[1],
      first_name: attributes[2],
      last_name: attributes[3],
      age: attributes[4]
    }

    @sessions = []
  end

  def append_session(session)
    @sessions << session
  end

  def report_key
    @user_key ||= "#{attributes[:first_name]} #{attributes[:last_name]}"
  end
end

def parse_session(session)
  {
    user_id: session[1],
    session_id: session[2],
    browser: session[3],
    time: session[4],
    date: session[5]
  }
end

def collect_stats_from_user(report, user)
  report[:usersStats][user.report_key] ||= {}
  report[:usersStats][user.report_key].merge!(
    sessionsCount: user.sessions.count,
    totalTime: user.sessions.sum { |s| s[:time].to_i }.to_s + ' min.',
    longestSession: (user.sessions.max_by { |s| s[:time].to_i })[:time].to_s + ' min.',
    browsers: (browsers_str = user.sessions.map { |s| s[:browser].upcase }.sort.join(', ')),
    usedIE: browsers_str.match?(/INTERNET EXPLORER/),
    alwaysUsedChrome: user.sessions.none? { |s| !s[:browser].match?(/CHROME/) },
    dates: user.sessions.map { |s| s[:date].rstrip }.sort.reverse
  )

  report[:totalUsers] += 1
  report[:totalSessions] += user.sessions.count
  user.sessions.each { |s| report[:allBrowsers] << s[:browser].upcase }
end

def work(filename)
  # Отчёт в json
  #   - Сколько всего юзеров
  #   - Сколько всего уникальных браузеров
  #   - Сколько всего сессий
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом
  #
  #   - По каждому пользователю
  #     - сколько всего сессий
  #     - сколько всего времени
  #     - самая длинная сессия
  #     - браузеры через запятую
  #     - Хоть раз использовал IE?
  #     - Всегда использовал только Хром?
  #     - даты сессий в порядке убывания через запятую

  users = []
  sessions = []
  report = {
    totalUsers: 0,
    totalSessions: 0,
    allBrowsers: SortedSet.new,
    uniqueBrowsersCount: 0,
    usersStats: {}
  }

  current_user = nil

  # print_memory_usage

  file = File.open(filename)
  report_tmp = File.new('report_tmp.json', 'w+')

  file.each_line do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      if current_user
        collect_stats_from_user(report, current_user)
        write_user_stats(report_tmp, report, current_user.report_key)
      end
      current_user = User.new(attributes: cols)
    elsif cols[0] == 'session' && current_user
      current_user.append_session(parse_session(cols))
    end
  end

  # print_memory_usage

  file.close

  # Process last user.
  collect_stats_from_user(report, current_user)
  write_user_stats(report_tmp, report, current_user.report_key, false)

  report_tmp.write("}}\n")

  # print_memory_usage

  report[:uniqueBrowsersCount] = report[:allBrowsers].count
  report[:allBrowsers] = report[:allBrowsers].to_a.join(',')
  report.delete(:usersStats)
  report[:usersStats] = {}

  # print_memory_usage

  report_file = File.new('result.json', 'w+')

  # Prepare report for output.
  report_json = report.to_json
  report_json[-2..-1] = ''
  report_file.pos = 0
  report_file.write(report_json)

  # print_memory_usage

  # Join tempfile with report.
  report_tmp.rewind
  report_tmp.each_line { |line| report_file.write(line) }

  report_tmp.close
  report_file.close
  File.delete('report_tmp.json')

  # print_memory_usage
end

def write_user_stats(file, report, user_key, comma = true)
  json_stats = { user_key => report[:usersStats][user_key] }.to_json
  json_stats[0] = ''
  json_stats[-1] = ''
  json_stats << ',' if comma

  file.write(json_stats)

  report[:usersStats].delete(user_key)
end

def print_memory_usage
  _, size = `ps ax -o pid,rss | grep -E "^[[:space:]]*#{$$}"`.strip.split.map(&:to_i)
  puts "#{(size / 1024.0).round(2)} MB"

  (size / 1024.0).round(2)
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
    expected_result = '{"totalUsers":3,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","uniqueBrowsersCount":14,"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end

  def test_time
    time = Benchmark.realtime { work('data.txt') }
    assert_operator time, :<, 0.1
  end

  def test_memory
    mem_start = print_memory_usage
    work('data.txt')
    mem_end = print_memory_usage

    assert_operator mem_end - mem_start, :<=, 80
  end
end

class TestBenchmark < Minitest::Benchmark
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

  def bench_is_linear
    assert_performance_linear 0.99 do |n|
      # n is a range value
      File.write('result.json', '')
      File.write('data.txt', '')
      n.times do
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
', mode: 'a')
      end
      work('data.txt')
    end
  end
end

# RubyProf.measure_mode = RubyProf::MEMORY
#
# result = RubyProf.profile do
#   work('data_large.txt')
# end
#
# printer = RubyProf::CallTreePrinter.new(result)
# printer.print(path: 'reports', profile: 'profile')

# report = MemoryProfiler.report do
#   work('data.txt')
# end
#
# report.pretty_print(scale_bytes: true)