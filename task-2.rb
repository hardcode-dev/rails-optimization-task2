# frozen_string_literal: true

# Deoptimized version of homework task

require 'set'
require 'oj'

def parse_session(fields)
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def stats_for_user(sessions)
  times = sessions.map { |s| s['time'] }
  browsers = sessions.map { |s| s['browser'] }.sort!

  {
    'sessionsCount' => sessions.count,
    'totalTime' => "#{times.sum} min.",
    'longestSession' => "#{times.max} min.",
    'browsers' => browsers.join(', '),
    'usedIE' => browsers.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => browsers.all? { |b| b =~ /CHROME/ },
    'dates' => sessions.map { |s| s['date'] }.sort!.reverse!
  }
end

def work(file)
  puts "Start"

  uniqueBrowsers = Set.new
  totalSessions = 0
  totalUsers = 0

  user_key = nil
  user_sessions = nil

  result_file = File.open('result.json', 'a')

  writer = Oj::StreamWriter.new(result_file)
  writer.push_object
  writer.push_key('usersStats')
  writer.push_object

  IO.foreach(file, chomp: true) do |line|
    fields = line.split(',')

    if fields[0] == 'user'
      writer.push_value(stats_for_user(user_sessions), user_key) unless user_key.nil?

      user_key = "#{fields[2]} #{fields[3]}"
      user_sessions = []
      totalUsers += 1
    else
      session = parse_session(fields)
      user_sessions << session
      uniqueBrowsers << session['browser']
      totalSessions += 1
    end
  end

  writer.push_value(stats_for_user(user_sessions), user_key)
  writer.pop

  writer.push_value(totalUsers, 'totalUsers')
  writer.push_value(uniqueBrowsers.count, 'uniqueBrowsersCount')
  writer.push_value(totalSessions, 'totalSessions')
  writer.push_value(uniqueBrowsers.sort.join(','), 'allBrowsers')
  writer.pop

  result_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts "Finish"
end
