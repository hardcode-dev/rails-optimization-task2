# Deoptimized version of homework task

require 'oj'
require 'set'

def work(path = ENV['DATA_FILE'], disable_gc: false)
  @user = nil
  @total_users = 0
  @total_sessions = 0
  @all_browsers = Set.new

  File.open("result.json", "a") do |output|
    output.write('{"usersStats":{')

    File.foreach(path, chomp: '\n') do |line|
      cols = line.split(',')

      if cols[0] == 'user'
        write_user(@user, output) if @user

        @user = parse_user(cols)
        @total_users += 1
      else
        @user['sessions'] << parse_session(cols)
        @total_sessions += 1

        @all_browsers << @user['sessions'].last['browser']
      end
    end

    write_user(@user, output, true)

    output.write("},\"totalUsers\":#{@total_users},\"uniqueBrowsersCount\":#{@all_browsers.size}," \
                 "\"totalSessions\":#{@total_sessions},\"allBrowsers\":\"#{ @all_browsers.sort.to_a.join(',')}\"}")
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
    'sessions' => [],
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4].to_i,
    'date' => fields[5],
  }
end

def write_user(user, output, last = false)
  sessions_time = []
  browsers = []
  dates = []

  user['sessions'].each do |s|
    sessions_time << s['time']
    browsers << s['browser']
    dates << s['date']
  end

  always_chrome = browsers.all? { |b| b.start_with?('CHROME') }

  user_stats = {
    # Собираем количество сессий по пользователям
    'sessionsCount' => user['sessions'].count,

    # Собираем количество времени по пользователям
    'totalTime' => sessions_time.sum.to_s + ' min.',

    # Выбираем самую длинную сессию пользователя
    'longestSession' => sessions_time.max.to_s + ' min.',

    # Браузеры пользователя через запятую
    'browsers' => browsers.sort.join(', '),

    # Хоть раз использовал IE?
    'usedIE' => always_chrome ? false : browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },

    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => always_chrome,

    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => dates.sort.reverse,
  }

  output.write("\"#{user['first_name']} #{user['last_name']}\":#{Oj.dump user_stats}")
  output.write(',') unless last
end
