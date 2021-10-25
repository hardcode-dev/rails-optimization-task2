# 5
# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'minitest'
require 'minitest/autorun' if ENV['RACK_ENV'] == 'test'
require 'minitest/benchmark' if ENV['RACK_ENV'] == 'test'
require 'memory_profiler' if ENV['RACK_ENV'] == 'benchmark'
require 'ruby-prof' if ENV['RACK_ENV'] == 'benchmark'
require 'stackprof' if ENV['RACK_ENV'] == 'benchmark'
require 'set'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report[user_key] ||= {}
    report[user_key] = report[user_key].merge(block.call(user))
  end
end

def work
  file_name = 'dataN.txt'
  file_name = 'data.txt' if ENV['RACK_ENV'] == 'test'
  file_lines_count = `wc -l "#{file_name}"`.strip.split(' ')[0].to_i
  file_lines = File.foreach(file_name)

  report_file = 'result.json'

  
  File.write(report_file, '{"usersStats":{', mode: 'a')

  current_user = nil
  user_sessions = []

  users_count = 0
  browsers = Set.new
  sessions_count = 0

  file_lines.with_index do |line, line_no|
    cols = line.chomp.split(',')

    if cols[0] == 'session'
      session = parse_session(cols)

      sessions_count += 1
      browsers.add(cols[3])

      user_sessions << session
    end

    if cols[0] == 'user' || line_no == file_lines_count-1
      if !current_user.nil?
        # Статистика по пользователю
        users_objects = []

        # Отчёт в json
        #   - По каждому пользователю
        #     - сколько всего сессий +
        #     - сколько всего времени +
        #     - самая длинная сессия +
        #     - браузеры через запятую +
        #     - Хоть раз использовал IE? +
        #     - Всегда использовал только Хром? +
        #     - даты сессий в порядке убывания через запятую +
        report = {}

        user_object = User.new(attributes: parse_user(current_user), sessions: user_sessions)
        users_objects << user_object

        # Собираем количество сессий по пользователям
        collect_stats_from_users(report, users_objects) do |user|
          { 'sessionsCount' => user.sessions.count }
        end

        # Собираем количество времени по пользователям
        collect_stats_from_users(report, users_objects) do |user|
          { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
        end

        # Выбираем самую длинную сессию пользователя
        collect_stats_from_users(report, users_objects) do |user|
          { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
        end

        # Браузеры пользователя через запятую
        collect_stats_from_users(report, users_objects) do |user|
          { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
        end

        # Хоть раз использовал IE?
        collect_stats_from_users(report, users_objects) do |user|
          { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
        end

        # Всегда использовал только Chrome?
        collect_stats_from_users(report, users_objects) do |user|
          { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
        end

        # Даты сессий через запятую в обратном порядке в формате iso8601
        collect_stats_from_users(report, users_objects) do |user|
          { 'dates' => user.sessions.map! { |s| s['date'] }.sort.reverse }
        end



        File.write(report_file, report.to_json[1...-1], mode: 'a')
        File.write(report_file, ',', mode: 'a') if line_no != file_lines_count-1
        user_sessions = []
      end

      next if line_no == file_lines_count-1

      current_user = cols
      users_count += 1
    end
  end

  File.write(report_file, "},", mode: 'a')


  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  report = {}

  report[:totalUsers] = users_count

  # Подсчёт количества уникальных браузеров
  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = sessions_count

  report['allBrowsers'] =
    browsers
      .map { |b| b.upcase }
      .sort
      .join(',')

  File.write(report_file, "#{report.to_json[1...-1]}}\n", mode: 'a')
  
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

if ENV['RACK_ENV'] == 'test'
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
      expected_result = JSON.parse('{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}')
      assert_equal expected_result, JSON.parse(File.read('result.json'))
    end
  end
elsif ENV['RACK_ENV'] == 'benchmark'
  report = MemoryProfiler.report do
    work
  end
  report.pretty_print(scale_bytes: true)


  # RubyProf.measure_mode = RubyProf::ALLOCATIONS
  # # RubyProf.measure_mode = RubyProf::MEMORY
  # result = RubyProf.profile do
  #   work
  # end

  # printer = RubyProf::FlatPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/flat.txt', 'w+'))

  # printer = RubyProf::GraphHtmlPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))

  # printer = RubyProf::CallStackPrinter.new(result)
  # printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))


  # StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  #   work
  # end
  # # stackprof stackprof_reports/stackprof.dump
  # # stackprof stackprof_reports/stackprof.dump --method 'Object#work'

  # profile = StackProf.run(mode: :object, raw: true) do
  #   work
  # end
  # File.write('stackprof_reports/stackprof.json', JSON.generate(profile))
else
  work
end
