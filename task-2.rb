# frozen_string_literal: true

require 'json'

def parse_user(fields)
  {
    'id' => fields[1],
    'user_key' => "#{fields[2]} #{fields[3]}"
  }
end

def parse_session(fields)
  {
    'browser' => fields[3],
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def work(file_name = 'data.txt')
  users = []
  sessions = []
  report = {}
  report['totalUsers'] = 0
  report['totalSessions'] = 0
  unique_browsers = {}

  IO.foreach(file_name) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      users << parse_user(cols)
      report['totalUsers'] += 1
    else
      cols[3].upcase
      sessions << parse_session(cols)
      report['totalSessions'] += 1
      unique_browsers[cols[3]] = nil
    end
  end

  unique_browsers = unique_browsers.keys.sort

  report['unique_browsersCount'] = unique_browsers.count
  report['allBrowsers'] = unique_browsers.join(',')
  report['usersStats'] = {}

  users.each do |user|
    user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
    user_key = "#{user['first_name']} #{user['last_name']}"

    report['usersStats'][user_key] = {
      'sessionsCount' => user_sessions.count,
      'totalTime' => "#{user_sessions.map { |s| s['time'] }.sum} min.",
      'longestSession' => "#{user_sessions.map { |s| s['time'] }.max} min.",
      'browsers' => user_sessions.map { |s| s['browser'] }.join(', '),
      'usedIE' => user_sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => user_sessions.map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ },
      'dates' => user_sessions.map! { |s| s['date'] }
    }
  end

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
