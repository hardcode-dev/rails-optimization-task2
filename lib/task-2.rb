require 'json'
require 'pry'
require 'minitest/autorun'

DATA_DIRECTORY = "#{__dir__}/../data/".freeze
USER_STR = 'user'.freeze
SESSION_STR = 'session'.freeze
COMMA_STR = ','.freeze
COMMA_SPACE_STR = ', '.freeze
MIN_STR = ' min.'.freeze
SPACE_STR = ' '.freeze
QUOTE_STR = '"'.freeze
COLON_STR = ':'.freeze
OPEN_CURB_STR = '{'.freeze
CLOSE_CURB_STR = '}'.freeze

USER_ID_STR = 'user_id'.freeze
SESSION_ID_STR = 'session_id'.freeze
BROWSER_STR = 'browser'.freeze
TIME_STR = 'time'.freeze
DATE_STR = 'date'.freeze

SESSIONS_COUNT_STR = 'sessionsCount'.freeze
TOTAL_TIME_STR = 'totalTime'.freeze
LONGEST_SESSION_STR = 'longestSession'.freeze
BROWSERS_STR = 'browsers'.freeze
USED_IE_STR = 'usedIE'.freeze
ALWAYS_USED_CHROME_STR = 'alwaysUsedChrome'.freeze
DATES_STR = 'dates'.freeze

class User
  attr_reader :attributes
  attr_accessor :sessions, :key

  def initialize(attributes:)
    @attributes = attributes
    @key = attributes['first_name'] + SPACE_STR + attributes['last_name']
    @sessions = []
  end
end

def data_path(file_name)
  DATA_DIRECTORY + file_name
end

def parse_user(fields)
  attributes = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
  User.new(attributes: attributes)
end

def parse_session(fields)
  {
    USER_ID_STR => fields[1],
    SESSION_ID_STR => fields[2],
    BROWSER_STR => fields[3],
    TIME_STR => fields[4],
    DATE_STR => fields[5].strip,
  }
end

def json_key(word) # "word":
  QUOTE_STR + word + QUOTE_STR + COLON_STR
end

def write_user_stats(result, user) # "user_key":{"stat1":1,"stat2":"2"}
  times = user.sessions.map { |s| s[TIME_STR].to_i }
  browsers = user.sessions.map { |s| s[BROWSER_STR].upcase }

  result.write(json_key(user.key))
  result.write({
      SESSIONS_COUNT_STR => user.sessions.count,
      TOTAL_TIME_STR => times.sum.to_s + MIN_STR,
      LONGEST_SESSION_STR => times.max.to_s + MIN_STR,
      BROWSERS_STR => browsers.sort.join(COMMA_SPACE_STR),
      USED_IE_STR => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
      ALWAYS_USED_CHROME_STR => browsers.all? { |b| b =~ /CHROME/ },
      DATES_STR => user.sessions.map {|s| s[DATE_STR]}.sort.reverse,
    }.to_json)
end

def work(file_name, disable_gc: false)
  GC.disable if disable_gc

  users_count = `grep -R "^user" #{file_name} | wc -l`.strip.to_i
  lines_count = `wc -l #{file_name}`.strip.to_i
  last_line_index = lines_count - 1

  result = File.open('result.json', 'w')
  result.write(OPEN_CURB_STR + json_key('usersStats') + OPEN_CURB_STR) # {"usersStats":{
  total_sessions_count = 0
  unique_browsers = []

  current_user = nil

  File.open(file_name).each_line.with_index do |l, i|
    fields = l.split(COMMA_STR)
    if fields[0] == USER_STR
      if current_user
        write_user_stats(result, current_user)
        result.write(COMMA_STR)
      end

      current_user = parse_user(fields)
    end
    if fields[0] == SESSION_STR
      session = parse_session(fields)
      current_user.sessions << session

      total_sessions_count += 1
      unique_browsers << session[BROWSER_STR]
    end

    unique_browsers.uniq!
    # handle last user
    write_user_stats(result, current_user) if i == last_line_index
  end

  result.write(CLOSE_CURB_STR + COMMA_STR)
  result.write(json_key('totalUsers') + users_count.to_s + COMMA_STR)
  result.write(json_key('uniqueBrowsersCount') + unique_browsers.count.to_s + COMMA_STR)
  result.write(json_key('totalSessions') + total_sessions_count.to_s + COMMA_STR)
  result.write(json_key('allBrowsers') + QUOTE_STR + unique_browsers.map(&:upcase).sort.join(COMMA_STR) + QUOTE_STR)
  result.write(CLOSE_CURB_STR)

  result.close
end

class TestCorrectness < Minitest::Test
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
    expected_result = '{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49"}'
    assert_equal expected_result, File.read('result.json')
  end
end
