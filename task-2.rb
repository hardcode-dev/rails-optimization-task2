# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  {
    'first_name' => fields[2],
    'last_name' => fields[3]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def work(file_name = 'data/data.txt')

  user = nil
  sessions = []
  report = {}
  total_users = 0
  total_sessions = 0
  #browsers = Set[]
  browsers = []
  @f = File.open('result.json', 'w+')
  @f.write('{"usersStats":{')

  File.open(file_name,'r', chomp: true).each do |line|
    cols = line.chomp.split(',')
    if cols[0].start_with?('u')
      total_users += 1
      if user
        write_user_stats(user, sessions)
        sessions = []
      end
      user = parse_user(cols)
    else
      session = parse_session(cols)
      total_sessions += 1
      sessions << session
      browsers << session['browser']
    end
  end

  write_user_stats(user, sessions, '')
  browsers = browsers.uniq.sort
  report['totalUsers'] = total_users
  report['uniqueBrowsersCount'] = browsers.count
  report['totalSessions'] = total_sessions
  report['allBrowsers'] = browsers.join(',')
  @f.write('},')
  @f.write("#{report.to_json[1..-1]}")
  @f.close
end

def write_user_stats(user, sessions, ending = ',')
  report = { }
  user_key = "#{user['first_name']} #{user['last_name']}"
  report[user_key] = collect_stats_from_user(sessions)
  s = report.to_json
  @f.write("#{s[1..-2]}#{ending}")
end

def collect_stats_from_user(user_sessions)
  browsers = user_sessions.map { |s| s['browser'] }
  {
    'sessionsCount' => user_sessions.count,
    'totalTime' => "#{user_sessions.sum { |s| s['time'] }} min.",
    'longestSession' => "#{user_sessions.map { |s| s['time'] }.max} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    'dates' => user_sessions.map { |s| s['date'] }.sort.reverse
  }
end
