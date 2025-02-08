# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

def build_user_stat(user)
  "\"#{user[:name]}\":{" \
  "\"sessionsCount\":#{user[:s_count]}," \
  "\"totalTime\":\"#{user[:total_time]} min.\"," \
  "\"longestSession\":\"#{user[:longest_session]} min.\"," \
  "\"browsers\":\"#{user[:browsers].sort.join(', ')}\"," \
  "\"usedIE\":#{user[:used_ie]}," \
  "\"alwaysUsedChrome\":#{user[:only_chorme]}," \
  "\"dates\":#{user[:dates].sort.reverse}" \
  '}'
end

def work(file, disable_gc: true)
  GC.disable if [true, 'true'].include?(disable_gc)

  File.open('result.json', 'w') do |result_file|
    result_file.write('{"usersStats":{')

    user = {}
    current_use_id = nil
    total_users = 0
    total_sessions = 0
    uniq_browsers = Set.new

    File.foreach(file, chomp: true).each do |line|
      type, user_id, first, second, three, fourth = line.split(',')

      if current_use_id && current_use_id != user_id
        result_file.write(build_user_stat(user))
        result_file.write(',')
      end

      case type
      when 'user'
        user = {
          s_count: 0,
          total_time: 0,
          longest_session: 0,
          browsers: [],
          used_ie: false,
          only_chorme: true,
          dates: [],
          name: "#{first} #{second}"
        }
        current_use_id = user_id
        total_users += 1
      when 'session'
        user[:s_count] += 1

        time = three.to_i
        browser = second.upcase

        user[:total_time] += time
        user[:longest_session] = time if time > user[:longest_session]
        user[:browsers] << browser
        user[:used_ie] = true if user[:used_ie] == false && browser.include?('INTERNET EXPLORER')
        user[:only_chorme] = false if user[:only_chorme] == true && !browser.include?('CHROME')
        user[:dates] << fourth

        uniq_browsers.add(browser)
        total_sessions += 1
      end
    end
    result_file.write(build_user_stat(user))
    result_file.write('},')

    result_file.write("\"totalUsers\":#{total_users},")
    result_file.write("\"uniqueBrowsersCount\":#{uniq_browsers.count},")
    result_file.write("\"totalSessions\":#{total_sessions},")
    result_file.write("\"allBrowsers\":\"#{uniq_browsers.sort.join(',')}\"")
    result_file.write('}')
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end