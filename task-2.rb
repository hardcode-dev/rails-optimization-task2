require 'json'
require 'pry'
require 'date'
require 'oj'
require 'set'

SEPARATOR = ','.freeze
SPACE = ' '.freeze
USER = 'user'.freeze

def parse_user(fields)
  {
    'first_name' => fields[2],
    'last_name' => fields[3]
  }
end

def parse_session(fields)
  {
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def write_user(writer, current_user, current_user_name)
  writer.push_json(current_user.to_json, current_user_name)
end

def process_user(current_user)
  current_user['dates'].sort!.reverse!
  current_user['alwaysUsedChrome'] = current_user['browsers'].all? { |browser| browser.start_with?('CHROME') }
  current_user['usedIE'] = current_user['browsers'].any? { |browser| browser.start_with?('INTERNET EXPLORER') }
  current_user['browsers'] = current_user['browsers'].sort.join(', ')
  current_user['totalTime'] = current_user['totalTime'].to_s << ' min.'
  current_user['longestSession'] = current_user['longestSession'].to_s << ' min.'
end

def current_user_hash
  {
    'sessionsCount' => 0,
    'totalTime' => 0,
    'longestSession' => '',
    'browsers' => [],
    'usedIE' => false,
    'alwaysUsedChrome' => false,
    'dates' => []
  }
end

def work(filepath)
  users_count = 0
  sessions_count = 0
  uniqueBrowsers = Set.new
  current_user = nil
  current_user_name = ''

  File.open('result.json', 'w+') do |f|
    writer = Oj::StreamWriter.new(f)
    writer.push_object
    writer.push_object('usersStats')
    fields = []

    IO.foreach(filepath, chomp: true) do |line|
      fields.clear
      line.chomp.split(',') { |val| fields << val }

      if line.start_with?(USER)
        users_count += 1
        if current_user
          process_user(current_user)
          write_user(writer, current_user, current_user_name)
        end
        user = parse_user(fields)
        current_user_name = "#{user['first_name']} #{user['last_name']}"
        current_user = current_user_hash
      else
        sessions_count += 1

        session = parse_session(fields)

        current_user['sessionsCount'] += 1
        current_user['totalTime'] = current_user['totalTime'].to_i + session['time'].to_i
        current_user['longestSession'] = session['time'].to_i if current_user['longestSession'].to_i < session['time'].to_i
        current_user['browsers'] << session['browser'].upcase
        current_user['dates'] << session['date']

        uniqueBrowsers.add session['browser']
      end
    end

    process_user(current_user)

    write_user(writer, current_user, current_user_name)
    writer.pop

    writer.push_value(users_count, 'totalUsers')
    writer.push_value(uniqueBrowsers.count, 'uniqueBrowsersCount')
    writer.push_value(sessions_count, 'totalSessions')
    writer.push_value(uniqueBrowsers.map(&:upcase).sort.join(','), 'allBrowsers')
    writer.pop
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end