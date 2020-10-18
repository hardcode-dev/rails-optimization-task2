# frozen_string_literal: true

require 'oj'
require 'csv'
require 'set'

class User
  attr_reader :attributes, :sessions, :browsers
  attr_accessor :browsers, :session_durations, :session_dates

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @sessions_count = 0
    @sessions_total_time = 0
    @session_durations = []
    @session_dates = []
    @longest_session = 0
    @used_ie = false
    @chrome_fan = true
    @browsers = []
  end

  def key
    "#{attributes[:first_name]} #{attributes[:last_name]}"
  end

  def sessions_total_time
    "#{session_durations.sum} min."
  end

  def longest_session
    "#{session_durations.max} min."
  end

  def used_ie?
    browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
  end

  def chrome_fan?
    (sessions_count.positive? && browsers.all? { |b| b.start_with?('CHROME') })
  end

  def sessions_count
    @sessions.length
  end

  def user_stats
    { sessionsCount: sessions_count,
      totalTime: sessions_total_time,
      longestSession: longest_session,
      browsers: browsers.sort.join(', '),
      usedIE: used_ie?,
      alwaysUsedChrome: chrome_fan?,
      dates: session_dates.sort.reverse }
  end

  def to_string
    "\"#{key}\": " + Oj.dump(user_stats, mode: :compat)
  end
end

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }
end

def write_user(prev_user, result, user, users)
  if prev_user
    result.write(prev_user.to_string)
    users.delete([prev_user.attributes[:id]])
    result.write ','
  else
    result.write('{"usersStats": {')
  end
  user
end

def work(file_path = 'data_large.txt')
  result_file = 'result.json'
  sessions_count = 0
  users_count = 0
  browsers = SortedSet.new
  browsers_count = 0
  users = {}
  prev_user = nil

  result = File.new(result_file, "w")
  CSV.foreach(file_path).each do |fields|
    if fields[0] == 'user'
      user = User.new(attributes: parse_user(fields), sessions: [])
      users[fields[1]] = user
      users_count += 1
      prev_user = write_user(prev_user, result, user, users) unless prev_user.eql?(user)
    end

    next unless fields[0] == 'session'

    user = users[fields[1]]
    user.sessions << parse_session(fields)
    user.browsers << fields[3].upcase
    browsers << fields[3].upcase
    browsers_count += 1
    user.session_durations << fields[4].to_i
    user.session_dates << fields[5]
    sessions_count += 1
    # GC.compact
  end

  result.write(prev_user.to_string)
  result.write('},')
  result.write("\"totalUsers\": #{users.count},")
  result.write("\"uniqueBrowsersCount\": #{browsers.count},")
  result.write("\"totalSessions\": #{sessions_count},")
  result.write("\"allBrowsers\": \"#{browsers.to_a.join(',')}\"")
  result.write('}')
  result.close
  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

work if ARGV.length.positive?
