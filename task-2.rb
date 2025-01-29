# frozen_string_literal: true

# Optimized version of homework task
require 'minitest/autorun'
require 'set'
require 'oj'
require 'byebug'

class User
  attr_reader :full_name, :sessions_count, :browsers, :used_ie,
              :always_used_chrome, :dates, :total_time, :longest_session

  attr_writer :full_name

  def initialize(first_name = nil, last_name = nil)
    @sessions_count = 0
    @dates = []
    @browsers = []
    @used_ie = false
    @always_used_chrome = false
    @full_name = first_name + ' ' + last_name if first_name && last_name
    @total_time = 0
    @longest_session = 0
  end

  def session=(session)
    @sessions_count += 1
    @browsers << session[:browser].upcase
    @total_time += session[:time].to_i
    @dates << session[:date]
    if @longest_session < session[:time].to_i
      @longest_session = session[:time].to_i
    end
  end

  def stat
    Oj.dump({ 'sessionsCount' => sessions_count,
                  'totalTime' => total_time.to_s + ' min.',
                  'longestSession' => longest_session.to_s + ' min.',
                  'browsers' => browsers.sort.join(', '),
                  'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
                  'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
                  'dates' => dates.sort.reverse }, {})
  end
end

class Report
  def initialize
    @current_user = nil
    @browsers = Set.new([])
    @sessions = 0
    @users_count = 0
    @report_file = File.open('result.json', 'w')
    @report_file.write('{"usersStats":{')
    @previous_item_type = nil
  end

  def call(file_path = 'data.txt', disable_gc = false)
    File.open(file_path, 'r').each do |line|
      parse_line(line)
    end
    write_user
    @report_file.seek(-1, IO::SEEK_END)
    @report_file.write('},' + '"totalUsers":' + @users_count.to_s + ',"uniqueBrowsersCount":' +
                    @browsers.count.to_s + ',"totalSessions":' + @sessions.to_s +
                    ',"allBrowsers":' + '"' +
                    @browsers.sort.map(&:upcase).join(',') + '"' + '}' + "\n")
    @report_file.close
  end

  private

  def write_user
    @report_file.write('"' + @current_user.full_name + '":' + @current_user.stat + ',')
  end

  def parse_session(fields)
    @current_user.session = ({ browser: fields[3],
                               time: fields[4],
                               date: fields[5] })
    @browsers << fields[3]
    @sessions += 1
  end

  def parse_user(fields)
    @current_user = User.new(fields[2], fields[3])
    @users_count += 1
  end

  def parse_line(line)
    cols = line.chomp.split(',')
    item_type = cols[0]
    write_user if @previous_item_type == 'session' && item_type == 'user'
    parse_user(cols) if item_type == 'user'
    parse_session(cols) if item_type == 'session'
    @previous_item_type = item_type
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
    Report.new.call
    expected_result = '{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}' + "\n"
    assert_equal expected_result, File.read('result.json')
  end
end
