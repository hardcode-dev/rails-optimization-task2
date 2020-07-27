# Deoptimized version of homework task

require 'json'
require 'pry'


def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
  }
end

def work
  File.write('result.json', "{\"usersStats\":{")

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
  user_sessions = []

  user_attr = nil
  File.foreach('data.txt', chomp: true) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      unless user_attr.nil?
        report = {
          'sessionsCount' => user_session_count, # Собираем количество сессий по пользователям
          'totalTime' => user_total_time.to_s + ' min.', # Собираем количество времени по пользователям
          'longestSession' => user_longest_session.to_s + ' min.', # Выбираем самую длинную сессию пользователя
          'browsers' => user_browsers.sort.join(', '), # Браузеры пользователя через запятую
          'usedIE' => user_used_ie, # Хоть раз использовал IE?
          'alwaysUsedChrome' => user_always_used_chrome, # Всегда использовал только Chrome?
          'dates' => user_dates.sort.reverse
        }

        File.write('result.json', "\"#{user_attr['first_name']} #{user_attr['last_name']}\":#{report.to_json},", mode: 'a')
      end

      total_users += 1
      user_session_count = 0
      user_total_time = 0
      user_longest_session = 0
      user_browsers = []
      user_used_ie = false
      user_always_used_chrome = true
      user_dates = []
      user_sessions = []

      user_attr = parse_user(line)
    end

    if cols[0] == 'session'
      session_attr = parse_session(line)

      user_sessions = user_sessions + [session_attr]

      user_session_count += 1
      user_total_time += session_attr['time'].to_i
      user_longest_session = session_attr['time'].to_i if user_longest_session < session_attr['time'].to_i

      # Подсчёт количества уникальных браузеров
      browser = session_attr['browser']

      user_browsers << browser
      user_used_ie = true if !user_used_ie && browser =~ /INTERNET EXPLORER/
      user_always_used_chrome = false if user_always_used_chrome && browser != ~/CHROME/
      user_dates << session_attr['date']

      if unique_browsers.all? { |b| b != browser }
        unique_browsers += [browser]
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

  File.write('result.json', "\"#{user_attr['first_name']} #{user_attr['last_name']}\":#{report.to_json}", mode: 'a')

  final_report = "}," \
    "\"totalUsers\": #{total_users}," \
    "\"uniqueBrowsersCount\":#{unique_browsers.size}," \
    "\"totalSessions\":#{total_sessions}," \
    "\"allBrowsers\":\"#{unique_browsers.sort.join(',')}\""

  File.write('result.json', "#{final_report}}\n", mode: 'a')

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
