# frozen_string_literal: true

require 'oj'
require 'pry'

def work(benchmark: false)
  file = File.open('result.json', 'w')

  file.write("{\"usersStats\":{")

  total_users = 0
  unique_browsers = []
  unique_browsers_count = 0
  total_sessions = 0

  user_session_count = 0
  user_total_time = 0
  user_longest_session = 0
  user_browsers = []
  user_used_ie = false
  user_always_used_chrome = true
  user_dates = []
  user_full_name = nil

  if benchmark
    puts 'ObjectSpace count objects: '
    pp ObjectSpace.count_objects
    puts GC.stat
    puts "MEMORY USAGE before iteration: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  File.foreach('data.txt', chomp: true) do |line|
    fields = []
    index = 0

    line_size = line.size
    step = 0

    while step < line_size
      if line[step] == ','
        index += 1
      else
        fields[index] ||= ''.dup
        fields[index] << line[step]
      end
      step += 1
    end

    if fields[0] == 'user'
      unless user_full_name.nil?
        report = {
          'sessionsCount' => user_session_count, # Собираем количество сессий по пользователям
          'totalTime' => user_total_time.to_s + ' min.', # Собираем количество времени по пользователям
          'longestSession' => user_longest_session.to_s + ' min.', # Выбираем самую длинную сессию пользователя
          'browsers' => user_browsers.sort.join(', '), # Браузеры пользователя через запятую
          'usedIE' => user_used_ie, # Хоть раз использовал IE?
          'alwaysUsedChrome' => user_always_used_chrome, # Всегда использовал только Chrome?
          'dates' => user_dates.sort.reverse
        }

        file.write("#{Oj.dump(report)},")
      end

      total_users += 1
      user_session_count = 0
      user_total_time = 0
      user_longest_session = 0
      user_browsers = []
      user_used_ie = false
      user_always_used_chrome = true
      user_dates = []

      user_full_name = fields[2] << ' ' << fields[3]

      file.write("\"#{user_full_name}\":")
    end

    if fields[0] == 'session'
      user_session_count += 1
      session_time = fields[4].to_i

      user_total_time += session_time
      user_longest_session = session_time if user_longest_session < session_time

      browser = fields[3].upcase!

      user_browsers << browser
      user_used_ie = true if !user_used_ie && browser =~ /INTERNET EXPLORER/
      user_always_used_chrome = false if user_always_used_chrome && browser != ~/CHROME/
      user_dates << fields[5]

      if unique_browsers.all? { |b| b != browser }
        unique_browsers << browser
        unique_browsers_count += 1
      end

      total_sessions += 1
    end
  end

  report = {
    'sessionsCount' => user_session_count, # Собираем количество сессий по пользователям
    'totalTime' => user_total_time.to_s + ' min.', # Собираем количество времени по пользователям
    'longestSession' => user_longest_session.to_s + ' min.', # Выбираем самую длинную сессию пользователя
    'browsers' => user_browsers.sort.join(', '), # Браузеры пользователя через запятую
    'usedIE' => user_used_ie, # Хоть раз использовал IE?
    'alwaysUsedChrome' => user_always_used_chrome, # Всегда использовал только Chrome?
    'dates' => user_dates.sort.reverse
  }

  file.write("#{Oj.dump(report)}")

  # if benchmark
  #   puts 'ObjectSpace count objects: '
  #   pp ObjectSpace.count_objects
  #   puts GC.stat
  #   puts "MEMORY USAGE after iteration: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  # end

  final_report = "}," \
    "\"totalUsers\": #{total_users}," \
    "\"uniqueBrowsersCount\":#{unique_browsers.size}," \
    "\"totalSessions\":#{total_sessions}," \
    "\"allBrowsers\":\"#{unique_browsers.sort.join(',')}\""

  file.write("#{final_report}}\n")
  file.close
end
