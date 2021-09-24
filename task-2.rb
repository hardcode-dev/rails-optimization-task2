# Deoptimized version of homework task

require 'oj'
require 'json'
require 'pry'
require 'date'

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'key' => "#{fields[2]}" + ' ' + "#{fields[3]}",
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work(file_path)
  users = {}
  users_count = 0
  sessions_count = 0
  stats = {}
  allBrowsers = []

  File.foreach(file_path, chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user = parse_user(line)
      users[user['id']] = user['key']
      stats[user['key']] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: false,
        dates: []
      }
      users_count += 1
    elsif cols[0] == 'session'
      session = parse_session(line)
      browser = session['browser'].upcase
      user_stats = stats[users[session['user_id']]]
      session_time = session['time'].to_i
      user_stats[:sessionsCount] += 1
      user_stats[:totalTime] += session_time
      user_stats[:longestSession] = session_time if session_time > user_stats[:longestSession]
      user_stats[:browsers] << browser
      user_stats[:usedIE] = true if browser =~ /INTERNET EXPLORER/
      if sessions_count == 0
        user_stats[:alwaysUsedChrome] = true if browser =~ /CHROME/
      else
        user_stats[:alwaysUsedChrome] = true if user_stats[:alwaysUsedChrome] && (browser =~ /CHROME/)
      end
      user_stats[:dates] << session['date']
      sessions_count += 1
      allBrowsers << browser
    end
  end

  allBrowsers = allBrowsers.sort.uniq

  io = File.new('result.json','w+')
  oj = Oj::StreamWriter.new(io)
  oj.push_object()
  oj.push_value(users_count, 'totalUsers')
  oj.push_value(allBrowsers.count, 'uniqueBrowsersCount')
  oj.push_value(sessions_count, 'totalSessions')
  oj.push_value(allBrowsers.join(','), 'allBrowsers')
  oj.push_object('usersStats')
  stats.each do |name, data|
    oj.push_object(name)
    oj.push_value(data[:sessionsCount], 'sessionsCount')
    oj.push_value("#{data[:totalTime]} min.", 'totalTime')
    oj.push_value("#{data[:longestSession]} min.", 'longestSession')
    oj.push_value(data[:browsers].sort.join(', '), 'browsers')
    oj.push_value(data[:usedIE], 'usedIE')
    oj.push_value(data[:alwaysUsedChrome], 'alwaysUsedChrome')
    oj.push_value(data[:dates].sort.reverse, 'dates')
    oj.pop
  end
  oj.pop
  oj.pop
  io.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
