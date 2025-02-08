# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'

require 'benchmark'
require 'memory_profiler'
require 'stackprof'
require 'ruby-prof'

USER_FIELD = 'user'

# FILE_NAME = "data_large.txt"
FILE_NAME = "data.txt"

SAVE_FILE = "result.json"
SAVE_TYPE = "a"
COMMON = ","
USER_STATS_STR = '{"usersStats":{'
USER_STATS_CLOSE = '}}'

class Parser
  attr_reader :user_stats, :users, :common_info, :user, :report

  def initialize
    @user_stats = {}
    @users = {}
    @common_info = {
      total_users: 0,
      total_sessions: 0,
      all_browsers: Set.new
    }

    File.write('result.json', USER_STATS_STR)
  end

  def process
    File.open(SAVE_FILE, SAVE_TYPE) do |file|
      File.foreach(FILE_NAME) do |line|
        fields = line.chomp.split(COMMON)


        if fields[0] == USER_FIELD && user_stats[user]
          prepare_data(user)
          save_data(file)
          @users = {}
          @user_stats = {}

          common_info[:total_users] += 1

          @user = "#{fields[2]} #{fields[3]}"

          user_stats[user] = {}

          next
        end

        if fields[0] == USER_FIELD
          common_info[:total_users] += 1

          @user = "#{fields[2]} #{fields[3]}"

          user_stats[user] = {}

          next
        end

        process_sessions(fields)
      end

      prepare_data(user)
      save_data(file)
      @users = {}
      @user_stats = {}

      save_finally_report_data(file)
    end
  end

  def process_sessions(fields)
    browser = fields[3].upcase
    time = fields[4].to_i
    date = fields[5]

    common_info[:total_sessions] += 1
    common_info[:all_browsers] << browser

    user_stats[:sessions_count] ||= 0
    user_stats[:sessions_count] += 1

    user_stats[:total_time] ||= 0
    user_stats[:total_time] += time

    user_stats[:longest_session] ||= 0
    user_stats[:longest_session] = [user_stats[:longest_session], time].max

    user_stats[:browsers] ||= []
    user_stats[:browsers].append(browser)

    user_stats[:dates] ||= []
    user_stats[:dates].append(date)
  end

  def prepare_data(user)
    users[user] = {
      sessionsCount: user_stats[:sessions_count],
      totalTime: "#{user_stats[:total_time]} min.",
      longestSession: "#{user_stats[:longest_session]} min.",
      browsers: user_stats[:browsers].sort.join(', '),
      usedIE: user_stats[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ },
      alwaysUsedChrome: user_stats[:browsers].all? { |b| b =~ /CHROME/ },
      dates: user_stats[:dates].sort.reverse
    }
  end

  def save_data(file)
    file.write "#{user.to_json}:#{users[user].to_json}"
    file.write COMMON
  end

  def save_finally_report_data(file)
    file.write "\"totalUsers\":#{common_info[:total_users].to_json}"
    file.write COMMON

    file.write "\"uniqueBrowsersCount\":#{common_info[:all_browsers].count.to_json}"
    file.write COMMON

    file.write "\"totalSessions\":#{common_info[:total_sessions].to_json}"
    file.write COMMON

    file.write "\"allBrowsers\":#{common_info[:all_browsers].sort.join(',').to_json}"
    file.write USER_STATS_CLOSE
  end
end

def work
  print_memory_usage

  Parser.new.process

  print_memory_usage
end

# RSS - Resident Set Size
# объём памяти RAM, выделенной процессу в настоящее время
def print_memory_usage
  p "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
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
    expected_result = JSON.parse('{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]},"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end

  # def test_memory_profiler
  #   report = MemoryProfiler.report do
  #     work
  #   end
  #
  #   report.pretty_print(scale_bytes: true)
  # end

  # def test_stackprof
  #   StackProf.run(mode: :object, out: 'stackprof_reports/stackprof.dump', raw: true) do
  #     work
  #   end
  # end

  # def test_rubuprof
  #   RubyProf.measure_mode = RubyProf::ALLOCATIONS
  #
  #   result = RubyProf.profile do
  #     work
  #   end
  #
  #   printer = RubyProf::GraphHtmlPrinter.new(result)
  #   printer.print(File.open('ruby_prof_reports/graph.html', 'w+'))
  #
  #   printer = RubyProf::CallStackPrinter.new(result)
  #   printer.print(File.open('ruby_prof_reports/callstack.html', 'w+'))
  # end

  # def test_rubuprof_memory
  #   RubyProf.measure_mode = RubyProf::MEMORY
  #
  #   result = RubyProf.profile do
  #     work
  #   end
  #
  #   printer = RubyProf::CallTreePrinter.new(result)
  #   printer.print(path: 'ruby_prof_reports', profile: 'profile')
  # end
end
