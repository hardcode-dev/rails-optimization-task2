# frozen_string_literal: true
require 'json'
require 'benchmark'

def work(file_name: 'files/data_large.txt', rows_count: nil)
  time = Benchmark.realtime do
    puts "Memory using BEFORE ALL #{print_memory_usage}"
    File.delete('files/result.json')
    @result = File.new('files/result.json', 'a')
    @result.print("{\"usersStats\":{")
    @total_users = 0
    @unique_browsers_count = 0
    @total_sessions = 0
    @all_browsers = []
    file = open file_name

    while line = file.gets&.chomp
      parse_line(line)
    end
    write_former_user
    puts "Memory using after parse lines #{print_memory_usage}"

    @result.print("},\"totalUsers\":#{@total_users},\"uniqueBrowsersCount\":#{@all_browsers.uniq.count},\"totalSessions\":#{@total_sessions},\"allBrowsers\":\"#{@all_browsers.uniq.sort.join(',')}\"}")
    @result.close
    puts "Memory using AFTER ALL #{print_memory_usage}"
  end
  puts "Finish in #{time.round(2)}"
end

def parse_line(line)
  cols = line.split(',')
  if cols.first == 'user'
    write_former_user
    parse_user(cols[1].to_i, cols)
  else
    parse_session(cols)
  end
end

def write_former_user
  return if @user.nil?

  @result.print(",") if @user_added_already
  @result.print("\"#{@user[0]} #{@user[1]}\":#{statistic_for_user(@user)}")
  @user_added_already = true
end

def parse_user(id, user)
  @user = [user[2], user[3], 0, 0, 0, [], []]
  @total_users += 1
end

def parse_session(session)
  browser = session[3].upcase
  @all_browsers = @all_browsers | [browser]
  @total_sessions += 1

  collect_statistics(session[1].to_i, session[4].to_i, browser, session[5])
end

def collect_statistics(id, time, browser, date)
  @user[2] += 1
  @user[3] += time
  @user[4] = time if time > @user[4]
  @user[5] << browser
  @user[6] << date
end

def statistic_for_user(user_array)
  "{\"sessionsCount\":#{user_array[2]},\"totalTime\":\"#{user_array[3]} min.\",\"longestSession\":\"#{user_array[4]} min.\",\"browsers\":\"#{user_array[5].sort.join(', ')}\",\"usedIE\":#{!user_array[5].find { |browser| browser =~ /INTERNET EXPLORER/ }.nil?},\"alwaysUsedChrome\":#{user_array[5].all? { |browser| browser =~ /CHROME/ }},\"dates\":#{user_array[6].sort.reverse}}"
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

work(file_name: 'files/data_large.txt')
