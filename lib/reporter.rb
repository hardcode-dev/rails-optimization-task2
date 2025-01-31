# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require_relative 'process_watcher'


def parse_user(user)
  _, id, first_name, last_name, age  = user.split(',')
  {
    id:,
    first_name: ,
    last_name:,
    age: age.strip!,
    sessions_count: 0,
    sessions_time: 0,
    longest_session: 0,
    browsers: [],
    dates: [],
    use_ie: false,

  }
end

def parse_session(session)
  _, user_id, session_id, browser, time, date = session.split(',')
  {
    user_id:,
    session_id:,
    browser:,
    time:,
    date: date.strip!,
  }
end

def collect_stats_from_user(user)
  { 'sessionsCount' => user[:sessions_count],
    'totalTime' => "#{user[:sessions_time]} min.",
    'longestSession' => "#{user[:longest_session]} min.",
    'browsers' => user[:browsers].join(', '),
    'usedIE' =>  user[:use_ie],
    'alwaysUsedChrome' => user[:browsers].all? { |b| b.upcase =~ /CHROME/ },
    'dates' => user[:dates].sort.reverse
  }
end

def work(source_path, report_file_path, options = {})
  GC.disable if options[:gc_disable]
  # Запускаем наш вотчер
  watcher, log_file = ProcessWatcher.new(pid: Process.pid, limit: 70).watch if options[:watcher_enable]
  

  file_data = File.open(source_path, 'r')
  File.write(report_file_path, '')
  file = File.open(report_file_path, 'w')
  file.write('{"usersStats":{')
  
  users_count = 0
  unique_browsers = []
  users_objects = {}
  sessions_count = 0
  delimeter = ', '
  current_user_id = nil
 
  while true
    line = file_data.gets
    delimeter = nil unless line
    if (line && current_user_id && line =~ /user/) || !line
      user_data = users_objects[current_user_id]
      key = "#{user_data[:first_name]} #{user_data[:last_name]}"
      file.write("\"#{key}\":")
      file.write("#{collect_stats_from_user(user_data).to_json}#{delimeter}")
      users_objects.delete(current_user_id)
    end

    break unless line

    if line =~ /user/
      users_count += 1
      user_attr = parse_user(line)
      current_user_id = user_attr[:id]
      users_objects[user_attr[:id]] ||= {}
      users_objects[user_attr[:id]] = user_attr 
    else
      sessions_count += 1
      sessions_attr = parse_session(line)
      browser = sessions_attr[:browser].upcase
      time = sessions_attr[:time].to_i
      unique_browsers << browser unless unique_browsers.include?(browser)
      user = users_objects[sessions_attr[:user_id]]
      if user
        user[:sessions_count] += 1
        user[:sessions_time] += time
        user[:longest_session] = time if user[:longest_session] < time
        user[:browsers] << browser
        user[:browsers].sort!
        user[:use_ie] = true if browser =~ /INTERNET EXPLORER/
        user[:dates] << sessions_attr[:date]
      end
    end
  end

  file.write("}, ")
  file.write("\"totalUsers\": #{users_count}, ")
  file.write("\"uniqueBrowsersCount\": #{unique_browsers.size}, ")
  file.write("\"totalSessions\": #{sessions_count}, ")
  file.write("\"allBrowsers\": \"#{unique_browsers.sort.join(',')}\"}")

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

  watcher.kill and log_file.close if watcher
  file.close
end



