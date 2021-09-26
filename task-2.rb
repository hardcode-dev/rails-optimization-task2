# Deoptimized version of homework task

require 'oj'
require 'pry'
require 'set'

class User
  attr_reader :id, :name
  attr_accessor :sessions

  def initialize(id, name)
    @id = id
    @name = name
    @sessions = []
  end

  def calculate_stats
    result = {
      sessionsCount: 0,
      totalTime: 0,
      longestSession: 0,
      browsers: [],
      usedIE: false,
      alwaysUsedChrome: false,
      dates: []
    }
    sessions.each do |session|
      session_time = session['time'].to_i
      result[:sessionsCount] += 1
      result[:totalTime] += session_time
      result[:longestSession] = session_time if session_time > result[:longestSession]
      browser = session['browser']
      result[:browsers] << browser
      result[:usedIE] = true if browser =~ /INTERNET EXPLORER/
      if result[:sessionsCount] == 0
        result[:alwaysUsedChrome] = true if browser =~ /CHROME/
      else
        result[:alwaysUsedChrome] = true if result[:alwaysUsedChrome] && (browser =~ /CHROME/)
      end
      result[:dates] << session['date']
    end
    result
  end
end

class UserStatsWriter
  def self.call(oj, user)
    stats = user.calculate_stats
    oj.push_object(user.name)
    oj.push_value(stats[:sessionsCount], 'sessionsCount')
    oj.push_value("#{stats[:totalTime]} min.", 'totalTime')
    oj.push_value("#{stats[:longestSession]} min.", 'longestSession')
    oj.push_value(stats[:browsers].sort.join(', '), 'browsers')
    oj.push_value(stats[:usedIE], 'usedIE')
    oj.push_value(stats[:alwaysUsedChrome], 'alwaysUsedChrome')
    oj.push_value(stats[:dates].sort.reverse, 'dates')
    oj.pop
  end
end

def work(file_path)
  users_count = 0
  sessions_count = 0
  all_browsers = SortedSet.new

  io = File.new('result.json','w+')
  oj = Oj::StreamWriter.new(io)
  oj.push_object()
  oj.push_object('usersStats')

  user = nil
  File.foreach(file_path, chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      UserStatsWriter.call(oj, user) if user
      user = User.new(cols[1], "#{cols[2]}" + ' ' + "#{cols[3]}")
      users_count += 1
    elsif cols[0] == 'session'
      session = {
        'user_id' => cols[1],
        'browser' => cols[3].upcase!,
        'time' => cols[4],
        'date' => cols[5],
      }
      user.sessions << session
      all_browsers.add(session['browser'])
      sessions_count += 1
    end
  end
  UserStatsWriter.call(oj, user)

  oj.pop

  allBrowsers = ''
  firstIteration = true
  all_browsers.each do |browser|
    if firstIteration
      allBrowsers = browser.dup
    else
      allBrowsers << ','
      allBrowsers << browser.dup
    end
    firstIteration = false
  end
  oj.push_value(users_count, 'totalUsers')
  oj.push_value(all_browsers.count, 'uniqueBrowsersCount')
  oj.push_value(sessions_count, 'totalSessions')
  oj.push_value(allBrowsers, 'allBrowsers')
  oj.pop
  io.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

work('data_large.txt')