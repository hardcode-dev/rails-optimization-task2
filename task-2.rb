# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

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
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def work(file_name: 'data.txt')
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
  File.open('result.json', 'w') do |file_result|
    file_result.write('{"usersStats":{')

    File.open(file_name, 'r') do |file|
      user = nil
      sessions = []
      total_users = 0
      total_sessions = 0
      unique_browsers = Set.new

      file.each_line do |line|
        if line.start_with?('user')
          unless user.nil?
            save_user(file_result, user:, sessions:)
            file_result.write(',')
          end

          user = parse_user(line)

          sessions = []
          total_users += 1
        else
          session = parse_session(line)

          sessions << session
          total_sessions += 1
          unique_browsers << session['browser'].upcase
        end
      end

      # Запись последнего пользователя и общей статистики
      unless user.nil?
        save_user(file_result, user:, sessions:)
        file_result.write('},') # usersStats

        save_common(file_result, total_users:, total_sessions:, unique_browsers:)

        file_result.write("}\n") # JSON
      end
    end
  end

  memory = (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts "MEMORY USAGE: #{memory} MB"
  memory
end

def save_user(file_result, user:, sessions:)
  file_result.write("\"#{user['first_name']} #{user['last_name']}\":")
  file_result.write(JSON.dump(
    {
      'sessionsCount' => sessions.count,
      'totalTime' => (sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'),
      'longestSession' => (sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'),
      'browsers' => sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      'usedIE' => sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      'dates' => sessions.map{|s| s['date']}.map {|d| Date.strptime(d)}.sort.reverse.map { |d| d.iso8601 }
    }
  ))
end

def save_common(file_result, total_users:, total_sessions:, unique_browsers:)
  file_result.write("\"totalUsers\":#{total_users},")
  file_result.write("\"uniqueBrowsersCount\":#{unique_browsers.count},")
  file_result.write("\"totalSessions\":#{total_sessions},")
  file_result.write("\"allBrowsers\":\"#{unique_browsers.sort.join(',')}\"")
end