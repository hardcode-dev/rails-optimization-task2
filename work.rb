DELIMITER = ','.freeze
COMMA = ', '.freeze

def write_sessions(f, cnt, time_sum, time_max, browsers, dates, ie, chrome)
  f.write <<-JSON
        \"sessionsCount\": #{cnt},
        \"totalTime\": "#{time_sum} min.",
        \"longestSession\": "#{time_max} min.",
        \"browsers\": "#{browsers.sort.join(COMMA)}",
        \"usedIE\": #{ie},
        \"alwaysUsedChrome\": #{chrome},
        \"dates\": #{dates.sort.reverse}
      }
  JSON
end

def work(filename = 'data.txt', gc: true, result: 'result.json')
  GC.disable unless gc

  uniqueBrowsers = Set.new
  totalSessions = 0
  totalUsers = 0
  # to see if we need a comma
  first_user = true
  user_label = 'user'.freeze
  session_label = 'session'.freeze

  time_sum = 0
  time_max = 0
  browsers = []
  dates = []
  ie = false
  chrome = true
  sessions_cnt = 0

  File.open(result, 'w') do |f|
    f.write("{ \"usersStats\":{")

    File.foreach(filename, chomp: true).each do |line|
      line_type, _, second, third, fourth, fifth = line.split(DELIMITER)

      if line_type == user_label
        unless first_user
          write_sessions(f, sessions_cnt, time_sum, time_max, browsers, dates, ie, chrome)
          f.write DELIMITER
        end

        f.write "\"#{second} #{third}\": {"
        first_user = false

        time_sum = 0
        time_max = 0
        browsers = []
        dates = []
        ie = false
        chrome = true
        sessions_cnt = 0

        totalUsers += 1
      elsif line_type == session_label
        third.upcase! # browser
        ctime = fourth.to_i

        time_sum += ctime
        time_max = ctime if ctime > time_max
        browsers << third
        unless ie
          ie = true if third =~ /INTERNET EXPLORER/
        end
        if chrome
          chrome = false unless third =~ /CHROME/
        end
        dates << fifth
        sessions_cnt += 1
        totalSessions += 1
        uniqueBrowsers.add(third)
      end
    end
    write_sessions(f, sessions_cnt, time_sum, time_max, browsers, dates, ie, chrome)

    f.write("},")
    f.write "\"uniqueBrowsersCount\": #{uniqueBrowsers.count},"
    f.write "\"totalSessions\": #{totalSessions},"
    f.write "\"allBrowsers\": \"#{uniqueBrowsers.sort.join(DELIMITER)}\","
    f.write "\"totalUsers\": #{totalUsers}"
    f.write("}")
  end

  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +

  # Подсчёт количества уникальных браузеров
end
