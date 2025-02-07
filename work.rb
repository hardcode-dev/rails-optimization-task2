# OptimizedUser = .new(:full_name, :sessions, keyword_init: true)

class OptimizedUser
  def initialize(full_name, sessions = [])
    @full_name = full_name
    @sessions = sessions
  end

  attr_accessor :full_name, :sessions
end

DELIMITER = ','.freeze
COMMA = ', '.freeze

def write_user_to_json(f, user, first_user: false)
  times = user.sessions.map { |s| s[3].to_i }
  browsers = user.sessions.map { |s| s[2] }
  dates = user.sessions.map { |s| s[4] }
  ie = browsers.any? { |b| b =~ /INTERNET EXPLORER/ }
  chrome = !ie && browsers.all? { |b| b =~ /CHROME/ }

  # File.open file, "a" do |f|
    f.write DELIMITER unless first_user
    f.write <<-JSON
      \"#{user.full_name}\": {
          \"sessionsCount\": #{user.sessions.count},
          \"totalTime\": "#{times.sum.to_s} min.",
          \"longestSession\": "#{times.max.to_s} min.",
          \"browsers\": "#{browsers.sort.join(COMMA)}",
          \"usedIE\": #{ie},
          \"alwaysUsedChrome\": #{chrome},
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
      session_or_user = line.split(DELIMITER)
      line_type = session_or_user.shift

      if line_type == user_label
        full_name = "#{session_or_user[1]} #{session_or_user[2]}"

        # write previous user
        if current_user
          write_user_to_json(f, current_user, first_user: first_user)
          first_user = false
        end

        current_user = OptimizedUser.new(full_name)
        totalUsers += 1
      elsif line_type == session_label
        session_or_user[2].upcase!
        current_user.sessions.push session_or_user
        totalSessions += 1
        uniqueBrowsers.add(session_or_user[2])
      end
    end
    write_user_to_json(f, current_user, first_user: false)

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
