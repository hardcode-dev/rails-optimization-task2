# frozen_string_literal: true

require 'json'

def aggregate_user_stats!(usersStats)
  usersStats[:longestSession] = "#{usersStats[:longestSession]} min."
  usersStats[:totalTime] = "#{usersStats[:totalTime]} min."
  usersStats[:browsers] = usersStats[:browsers].sort!.join(', ')
  usersStats[:dates] = usersStats[:dates].sort!.reverse!
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
def work(filepath = 'data.txt')
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: [],
  }

  usersStats = {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: true,
    dates: []
  }

  user_key = nil
  session_mode = nil
  col = 0
  output_file = File.open('result.json', 'w')
  output_file.write('{"usersStats":{')

  File.foreach(filepath, chomp: true) do |line|
    line.split(',') do |val|
      col += 1
      if val == 'user'
        if session_mode
          aggregate_user_stats!(usersStats)
          output_file.write("\"#{user_key}\":#{usersStats.to_json},")
        end
        session_mode = false
        usersStats = {
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: true,
          dates: []
        }
        user_key = nil
        col = 0
        report[:totalUsers] += 1
        next
      end
      if val == 'session'
        session_mode = true
        col = 0
        report[:totalSessions] += 1
        usersStats[:sessionsCount] += 1
        next
      end

      unless session_mode
        case col
        when 2
          user_key = val
        when 3
          user_key = "#{user_key} #{val}"
        end
      end

      if session_mode
        case col
        when 3
          unless report[:allBrowsers].include?(val.upcase!)
            report[:allBrowsers] << val
            report[:uniqueBrowsersCount] += 1
          end
          usersStats[:browsers] << val
          usersStats[:usedIE] ||= val.match?(/INTERNET EXPLORER/)
          usersStats[:alwaysUsedChrome] &&= val.match?(/CHROME/)
        when 4
          usersStats[:totalTime] += val.to_i
          usersStats[:longestSession] = val.to_i if usersStats[:longestSession] < val.to_i
        when 5
          usersStats[:dates] << val
        end
      end
    end
  end

  report[:allBrowsers] = report[:allBrowsers].sort!.join(',')

  aggregate_user_stats!(usersStats)
  output_file.write("\"#{user_key}\":#{usersStats.to_json}},#{report.to_json[1..-1]}")
  output_file.close
end
