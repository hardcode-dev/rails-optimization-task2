# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'date'

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|

    report[user_key] ||= {}
    report[user_key] = report[user_key].merge(block.call(user))
  end
end

def report_write_user(report_file, user)
  report = {}
  report['sessionsCount'] = user[:times].count
  report['totalTime'] = "#{user[:times].sum} min."
  report['longestSession'] = "#{user[:times].max} min."
  report['browsers'] = user[:browsers].sort.join(', ')
  report['usedIE'] = user[:browsers].any? { |b| b =~ /INTERNET EXPLORER/ }
  report['alwaysUsedChrome'] = user[:browsers].all? { |b| b =~ /CHROME/ }
  report['dates'] = user[:dates].sort!.reverse!

  report_file.write("\"#{user[:first_name]} #{user[:last_name]}\":#{report.to_json}")
end

def work(file_path = 'data/data.txt')
  report_file = File.open('result.json', 'w')
  report_file.write('{"usersStats":{')

  user = nil
  user_count = 0
  session_count = 0
  browsers = []

  IO.foreach(file_path) do |line|
    cols = line.chomp.split(',')
    if cols[0] == 'user'
      unless user.nil?
        report_write_user(report_file, user)
        report_file.write(',')
      end
      user = {
        first_name: cols[2],
        last_name: cols[3],
        times: [],
        browsers: [],
        dates: []
      }

      user_count += 1
    else
      browser = cols[3].upcase

      user[:times] << cols[4].to_i
      user[:dates] << cols[5]
      user[:browsers] << browser

      browsers << browser
      session_count += 1
    end
  end

  report_write_user(report_file, user)

  browsers.uniq!
  browsers.sort!

  report_file.write("},\"totalUsers\":#{user_count},")
  report_file.write("\"uniqueBrowsersCount\":#{browsers.count},")
  report_file.write("\"totalSessions\":#{session_count},")
  report_file.write("\"allBrowsers\":\"#{browsers.join(',')}\"}")
  report_file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
