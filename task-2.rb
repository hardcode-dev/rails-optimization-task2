# frozen_string_literal: true

require 'json'
require 'csv'
require 'set'

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|

    report[user_key] ||= {}
    report[user_key] = report[user_key].merge(yield(user))
  end
end

def write_user_info(report_file, user)
  report = {}
  report[:sessionsCount] = user[:times].count
  report[:totalTime] = "#{user[:times].sum} min."
  report[:longestSession] = "#{user[:times].max} min."
  report[:browsers] = user[:browsers].sort.join(', ')
  report[:usedIE] = user[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ }
  report[:alwaysUsedChrome] = user[:browsers].all? { |b| b =~ /CHROME/ }
  report[:dates] = user[:dates].sort!.reverse!

  report_file.write("\"#{user[:first_name]} #{user[:last_name]}\":#{report.to_json}")
end

def assign_initial_user_attributes(line)
  {
    first_name: line[2],
    last_name: line[3],
    times: [],
    browsers: [],
    dates: []
  }
end

def assign_session_user_attributes(user, line, browser)
  user[:times] << line[4].to_i
  user[:dates] << line[5]
  user[:browsers] << browser
end

def work(file_path)
  report_file = File.open('result.json', 'w')
  report_file.write('{"usersStats":{')

  user = nil
  user_count = 0
  session_count = 0
  unique_browsers = Set.new

  CSV.foreach(file_path) do |line|
    if line[0] == 'user'
      if user
        write_user_info(report_file, user)
        report_file.write(',')
      end

      user = assign_initial_user_attributes(line)
      user_count += 1
    else
      browser = line[3].upcase
      assign_session_user_attributes(user, line, browser)
      unique_browsers.add(browser)
      session_count += 1
    end
  end

  write_user_info(report_file, user)

  report_file.write("},\"totalUsers\":#{user_count},")
  report_file.write("\"uniqueBrowsersCount\":#{unique_browsers.count},")
  report_file.write("\"totalSessions\":#{session_count},")
  report_file.write("\"allBrowsers\":\"#{unique_browsers.sort.join(',')}\"}")
  report_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
