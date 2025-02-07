OptimizedUser = Struct.new(:full_name, :sessions, keyword_init: true)

def write_user_to_json(f, user, first_user: false)
  times = user.sessions.map { |s| s[4].to_i }
  browsers = user.sessions.map { |s| s[3] }
  dates = user.sessions.map { |s| s[5] }

  # File.open file, "a" do |f|
    f.write ',' unless first_user
    f.write <<-JSON
      \"#{user.full_name}\": {
          \"sessionsCount\": #{user.sessions.count},
          \"totalTime\": "#{times.sum.to_s} min.",
          \"longestSession\": "#{times.max.to_s} min.",
          \"browsers\": "#{browsers.sort.join(', ')}",
          \"usedIE\": #{browsers.any? { |b| b =~ /INTERNET EXPLORER/ }},
          \"alwaysUsedChrome\": #{browsers.all? { |b| b =~ /CHROME/ }},
          \"dates\": #{dates.sort.reverse}
        }
    JSON
  # end
end

def work(filename = 'data.txt', gc: true, result: 'result.json')
  GC.disable unless gc

  current_user = nil
  uniqueBrowsers = Set.new
  totalSessions = 0
  totalUsers = 0
  # to see if we need a comma
  first_user = true
  user_label = 'user'.freeze
  session_label = 'session'.freeze

  File.open(result, 'a') do |f|
    f.write("{ \"usersStats\":{")

    File.readlines(filename, chomp: true).each do |line|
      if line[0,4] == user_label
        _, _, first_name, last_name, _ = line.split(',')

        # write previous user
        if current_user
          write_user_to_json(f, current_user, first_user: first_user)
          first_user = false
        end

        current_user = OptimizedUser.new(full_name: "#{first_name} #{last_name}", sessions: [])
        totalUsers += 1
      elsif line[0,7] == session_label
        # _, user_id, session_id, browser, time, date = line.split(',')

        # OptimizedSession.new(user_id: user_id, session_id: session_id, browser: browser, time:)

        session =  line.split(',')
        session[3].upcase!
        # session = {
        #   'user_id' => user_id,
        #   'session_id' => session_id,
        #   'browser' => browser.upcase,
        #   'time' => time,
        #   'date' => date,
        # }

        # session = parse_session(cols)
        current_user.sessions.push session

        totalSessions += 1
        # uniqueBrowsers.add(session['browser'])
        uniqueBrowsers.add(session[3])

      end
    end
    write_user_to_json(f, current_user, first_user: false)

    f.write("},")

    f.write "\"uniqueBrowsersCount\": #{uniqueBrowsers.count},"
    f.write "\"totalSessions\": #{totalSessions},"
    f.write "\"allBrowsers\": \"#{uniqueBrowsers.sort.join(',')}\","
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

  # File.open result, "a" do |f|
  #   f.write "\"uniqueBrowsersCount\": #{uniqueBrowsers.count},"
  #   f.write "\"totalSessions\": #{totalSessions},"
  #   f.write "\"allBrowsers\": \"#{uniqueBrowsers.sort.join(',')}\","
  #   f.write "\"totalUsers\": #{totalUsers}"
  #   f.write("}")
  # end
end
