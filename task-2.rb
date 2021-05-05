# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
# require 'pry'
require 'set'

def parse_username(user)
  fields = user.split(',')
  "#{fields[2]} #{fields[3]}"
end

def parse_session(session)
  fields = session.split(',')
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

def save_user_report(user_report, file)
  save_username(user_report.delete('username'), file)
  user_report['totalTime'] = "#{user_report['totalTime']} min."
  user_report['longestSession'] = "#{user_report['longestSession']} min."
  user_report['browsers'] = user_report['browsers'].sort.join(', ')
  user_report['dates'] = user_report['dates'].sort.reverse
  file.write(user_report.to_json)
end

def save_username(username, file)
  file.write('"')
  file.write(username)
  file.write('":')
end

def work(filename = 'data.txt')
  report = {
    'totalUsers' => 0,
    'allBrowsers' => Set.new,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0
  }
  user_report = nil
  result_file = File.open('result.json', 'w')
  result_file.write('{"usersStats":{')

  File.foreach(filename, "\n", chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      if user_report
        save_user_report(user_report, result_file)
        result_file.write(',')
      end
      report['totalUsers'] += 1
      user_report = {
        'username' => parse_username(line),
        'sessionsCount' => 0,
        'totalTime' => 0,
        'longestSession' => 0,
        'browsers' => [],
        'usedIE' => false,
        'alwaysUsedChrome' => true,
        'dates' => []
      }
      next
    end
    session = parse_session(line)
    report['allBrowsers'].add(session['browser'])
    report['uniqueBrowsersCount'] = report['allBrowsers'].size
    report['totalSessions'] += 1

    user_report['sessionsCount'] += 1
    user_report['totalTime'] += session['time']
    user_report['longestSession'] = session['time'] if session['time'] > user_report['longestSession']
    user_report['browsers'].append(session['browser'])
    user_report['usedIE'] = true if session['browser'] =~ /INTERNET EXPLORER/
    user_report['alwaysUsedChrome'] = false unless session['browser'] =~ /CHROME/
    user_report['dates'].append(session['date'])
  end

  # end of usersStats
  save_user_report(user_report, result_file) if user_report
  result_file.write('}')
  # totalUsers
  result_file.write(',"totalUsers":')
  result_file.write(report['totalUsers'])
  # allBrowsers
  result_file.write(',"allBrowsers":"')
  result_file.write(report['allBrowsers'].to_a.sort!.join(','))
  result_file.write('"')
  # uniqueBrowsersCount
  result_file.write(',"uniqueBrowsersCount":')
  result_file.write(report['uniqueBrowsersCount'])
  # totalSessions
  result_file.write(',"totalSessions":')
  result_file.write(report['totalSessions'])
  # end of file
  result_file.write('}')

  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
ensure
  result_file.close
end
