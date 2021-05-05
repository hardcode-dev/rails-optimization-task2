# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
# require 'pry'
require 'set'

def parse_user(user)
  fields = user.split(',')
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
    'full_name' => "#{fields[2]} #{fields[3]}"
  }
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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = user.attributes['full_name']
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def work(filename = 'data.txt')
  report = {
    'totalUsers' => 0,
    'usersStats' => {},
    'allBrowsers' => Set.new,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0
  }
  current_user = {}

  File.foreach(filename, "\n", chomp: true) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      current_user = parse_user(line)
      report['totalUsers'] += 1
      report['usersStats'][current_user['full_name']] = {
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
    report['usersStats'][current_user['full_name']]['sessionsCount'] += 1
    report['usersStats'][current_user['full_name']]['totalTime'] += session['time']
    if session['time'] > report['usersStats'][current_user['full_name']]['longestSession']
      report['usersStats'][current_user['full_name']]['longestSession'] = session['time']
    end
    report['usersStats'][current_user['full_name']]['browsers'].append(session['browser'])
    report['usersStats'][current_user['full_name']]['usedIE'] = true if session['browser'] =~ /INTERNET EXPLORER/
    report['usersStats'][current_user['full_name']]['alwaysUsedChrome'] = false unless session['browser'] =~ /CHROME/
    report['usersStats'][current_user['full_name']]['dates'].append(session['date'])
  end

  # Сериализация данных
  report['allBrowsers'] = report['allBrowsers'].to_a.sort!.join(',')
  report['usersStats'].each_key do |user_name|
    report['usersStats'][user_name]['totalTime'] = "#{report['usersStats'][user_name]['totalTime']} min."
    report['usersStats'][user_name]['longestSession'] = "#{report['usersStats'][user_name]['longestSession']} min."
    report['usersStats'][user_name]['browsers'] = report['usersStats'][user_name]['browsers'].sort.join(', ')
    report['usersStats'][user_name]['dates'] = report['usersStats'][user_name]['dates'].sort.reverse
  end

  File.write('result.json', "#{report.to_json}\n")
  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end
