# Deoptimized version of homework task

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

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
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
  attributes = user
  user_object = User.new(attributes: attributes, sessions: user_sessions)
  user_key = "#{user_object.attributes['first_name']}" + ' ' + "#{user_object.attributes['last_name']}"

  report = {}
  report['sessionsCount'] = user_object.sessions.count
  report['totalTime'] = user_object.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'
  report['longestSession'] = user_object.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'
  report['browsers'] = user_object.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')
  report['usedIE'] = user_object.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
  report['alwaysUsedChrome'] = user_object.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }
  report['dates'] = user_object.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }

  report_file.write("\"#{user_key}\":#{report.to_json}")
end

def work(file_path = 'data/data.txt')
  report_file = File.open('result.json', 'w')
  report_file.write('{"usersStats":{')

  file_lines = File.read(file_path).split("\n")

  user = nil
  user_count = 0
  session_count = 0
  browser = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(',')
    if cols[0] == 'session'
      session = parse_session(line)
      browser << session['browser']
      sessions << session
      session_count += 1
    elsif cols[0] == 'user'
      unless user.nil?
        report_write_user(report_file, user, sessions)
        report_file.write(',')
      end
      user = parse_user(line)
      sessions = []
      user_count += 1
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
