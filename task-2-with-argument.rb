require 'json'
require 'oj'

class User
  attr_accessor :session_stats, :sessions, :first_name, :last_name

  def initialize(id, first_name, last_name, age)
    @id = id
    @first_name = first_name
    @last_name = last_name
    @age = age
    @sessions = []
    @session_stats = {}
  end
end

def parse_session(fields)
  {
    'user_id' => fields[0],
    'session_id' => fields[1],
    'browser' => fields[2],
    'time' => fields[3],
    'date' => fields[4]
  }
end

def collect_stats_from_user(user)
  return {} unless user

  stats = {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
    'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
    'browsers' => user.sessions.map {|s| s['browser']},
    'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
  }

  stats['usedIE'] = stats['browsers'].any? { |b| b =~ /INTERNET EXPLORER/ }
  stats['alwaysUsedChrome'] = stats['browsers'].all? { |b| b =~ /CHROME/ }
  stats['browsers'] = stats['browsers'].sort.join(', ')
  stats['dates'].sort!.reverse!
  stats
end

def write_user(user, stream_writer)
  stream_writer.push_key("#{user.first_name} #{user.last_name}")
  stream_writer.push_object
  user.session_stats.each { |key, value| stream_writer.push_value(value, key.to_s) }
  stream_writer.pop
end

def work(file_name)
  total_users = 0
  total_sessions = 0
  unique_browsers = Set.new
  user = nil

  result_file = File.open('result.json', 'w')

  stream_writer = Oj::StreamWriter.new(result_file)
  stream_writer.push_object
  stream_writer.push_key('usersStats')
  stream_writer.push_object

  File.foreach(file_name) do |line|
    type, *info = line.strip!.split(',')
    if type == 'user'
      total_users += 1
      user.session_stats = collect_stats_from_user(user) if user
      write_user(user, stream_writer) if user
      user = User.new(*info)
    end

    if type == 'session'
      total_sessions += 1
      session = parse_session(info)
      user.sessions << session
      unique_browsers << session['browser'].upcase!
    end
  end

    user.session_stats = collect_stats_from_user(user) if user
    write_user(user, stream_writer) if user

    stream_writer.pop

    stream_writer.push_value(total_users, 'totalUsers')
    stream_writer.push_value(unique_browsers.count, 'uniqueBrowsersCount')
    stream_writer.push_value(total_sessions, 'totalSessions')
    stream_writer.push_value(unique_browsers.sort.join(','), 'allBrowsers')

    stream_writer.pop_all
    result_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
