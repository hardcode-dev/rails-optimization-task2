# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
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
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5].chomp,
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|

    report[user_key] ||= {}
    report[user_key] = report[user_key].merge(block.call(user))
  end
end

def report_write_user(report_file, user, user_sessions)
  # Статистика по пользователям
  user_key = "#{user['first_name']} #{user['last_name']}"
  times = user_sessions.map {|s| s['time'].to_i }
  browser = user_sessions.map {|s| s['browser']}

  report = {}
  report['sessionsCount'] = user_sessions.count
  report['totalTime'] = "#{times.sum} min."
  report['longestSession'] = "#{times.max} min."
  report['browsers'] = browser.sort.join(', ')
  report['usedIE'] = browser.any? { |b| b =~ /INTERNET EXPLORER/ }
  report['alwaysUsedChrome'] = browser.all? { |b| b =~ /CHROME/ }
  report['dates'] = user_sessions.map{|s| s['date']}.sort.reverse

  report_file.write("\"#{user_key}\":#{report.to_json}")
end

def work(file_path = 'data/data.txt')
  report_file = File.open('result.json', 'w')
  report_file.write('{"usersStats":{')

  user = nil
  user_count = 0
  session_count = 0
  browser = []
  sessions = []

  IO.foreach(file_path) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      unless user.nil?
        report_write_user(report_file, user, sessions)
        report_file.write(',')
      end
      user = parse_user(cols)
      sessions = []
      user_count += 1
    else
      session = parse_session(cols)
      browser << session['browser']
      sessions << session
      session_count += 1
    end
  end

  report_write_user(report_file, user, sessions)

  browser.uniq!
  browser.sort!

  report_file.write("},\"totalUsers\":#{user_count},")
  report_file.write("\"uniqueBrowsersCount\":#{browser.count},")
  report_file.write("\"totalSessions\":#{session_count},")
  report_file.write("\"allBrowsers\":\"#{browser.join(',')}\"}")
  report_file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
