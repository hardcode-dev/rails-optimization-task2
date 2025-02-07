class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

# def parse_user(cols)
#   # _, id, first_name, last_name, age = cols.split(',')
#   {
#     'id' => cols[1],
#     'first_name' => cols[2],
#     'last_name' => cols[3],
#     'age' => cols[4],
#   }
# end

# def parse_session(cols)
#   # _, user_id, session_id, browser, time, date = cols.split(',')
#   {
#     'user_id' => cols[1],
#     'session_id' => cols[2],
#     'browser' => cols[3],
#     'time' => cols[4],
#     'date' => cols[5],
#   }
# end

def write_user_to_json(f, user, first_user: false)
  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"

  times = user.sessions.map { |s| s['time'].to_i }
  browsers = user.sessions.map { |s| s['browser'].upcase }

  dates = user.sessions.map { |s| s['date'] }

  # File.open file, "a" do |f|
    f.write ',' unless first_user
    f.write <<-JSON
      \"#{user_key}\": {
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

  File.open(result, 'a') do |f|
    f.write("{ \"usersStats\":{")

    File.readlines(filename, chomp: true).each do |line|
      if line[0,4] == 'user'
        _, id, first_name, last_name, age = line.split(',')

        # write previous user
        if current_user
          write_user_to_json(f, current_user, first_user: first_user)
          first_user = false
        end
        # parsed_user = parse_user(cols)
        parsed_user = {
          'id' => id,
          'first_name' => first_name,
          'last_name' => last_name,
          'age' => age,
        }

        current_user = User.new(attributes: parsed_user, sessions: [])
        totalUsers += 1
      elsif line[0,6] == 'session'
        _, user_id, session_id, browser, time, date = cols.split(',')

        session = {
          'user_id' => user_id,
          'session_id' => session_id,
          'browser' => browser,
          'time' => time,
          'date' => date,
        }

        # session = parse_session(cols)
        current_user.sessions.push session

        totalSessions += 1
        uniqueBrowsers.add(session['browser'].upcase)
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