#frozen_string_literal: true

require_relative 'memory_watcher'

def write_sessions(file, user_sessions_count, user_total_time, user_longest_session, user_browsers, user_dates, ie, chrome)
  file.write <<-JSON
        \"sessionsCount\": #{user_sessions_count},
        \"totalTime\": "#{user_total_time} min.",
        \"longestSession\": "#{user_longest_session} min.",
        \"browsers\": "#{user_browsers.sort.join(', ')}",
        \"usedIE\": #{ie},
        \"alwaysUsedChrome\": #{chrome},
        \"dates\": #{user_dates.sort.reverse}
      }
  JSON
end

def work(file_path = 'data.txt', memory_watcher = false)
  if memory_watcher
    memory_watcher = MemoryWatcher.new(70)
    memory_watcher.start
  end

  all_browsers = Set.new
  total_users = 0
  total_sessions = 0

  first_user = true
  user_sessions_count = 0
  user_total_time = 0
  user_longest_session = 0
  user_browsers = []
  ie = false
  chrome = true
  user_dates = []

  begin
    File.open("result.json", 'w') do |file|
      file.write("{ \"usersStats\":{")

      File.foreach(file_path, chomp: true).each do |line|
        record_type, _, user_name_or_session_id, user_second_name_or_browser_name, session_time, browser_date = line.split(',')
        if record_type == 'user'
          unless first_user
            write_sessions(file, user_sessions_count, user_total_time, user_longest_session, user_browsers, user_dates, ie, chrome)
            file.write ','
          end

          file.write "\"#{user_name_or_session_id} #{user_second_name_or_browser_name}\": {"
          total_users += 1
          first_user = false
          user_total_time = 0
          user_longest_session = 0
          user_browsers = []
          user_dates = []
          ie = false
          chrome = true
          user_sessions_count = 0
        elsif record_type == "session"
          user_session_time = session_time.to_i
          user_total_time += user_session_time

          user_longest_session = user_session_time if user_session_time > user_longest_session

          user_browsers << user_second_name_or_browser_name.upcase!

          unless ie
            ie = true if user_second_name_or_browser_name =~ /INTERNET EXPLORER/
          end
          if chrome
            chrome = false unless user_second_name_or_browser_name =~ /CHROME/
          end

          user_dates << browser_date
          user_sessions_count += 1
          total_sessions += 1
          all_browsers.add(user_second_name_or_browser_name)
        end
      end

      write_sessions(file, user_sessions_count, user_total_time, user_longest_session, user_browsers, user_dates, ie, chrome)

      file.write("},")
      file.write "\"uniqueBrowsersCount\": #{all_browsers.count},"
      file.write "\"totalSessions\": #{total_sessions},"
      file.write "\"allBrowsers\": \"#{all_browsers.sort.join(',')}\","
      file.write "\"totalUsers\": #{total_users}"
      file.write("}")
    end

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  ensure
    memory_watcher.stop if memory_watcher
  end
end
