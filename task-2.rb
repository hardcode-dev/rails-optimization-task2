# frozen_string_literal: true

require 'json'

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
    uniqueBrowsersCount: [],
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }
  user_key = ''
  user_mode = nil
  session_mode = nil
  col = 0

  File.foreach(filepath, chomp: true) do |line|
    line.split(',') do |val|
      col += 1
      if val == 'user'
        user_mode = true
        session_mode = false
        user_key = ''
        col = 0
        report[:totalUsers] += 1
        next
      end
      if val == 'session'
        user_mode = false
        session_mode = true
        col = 0
        report[:totalSessions] += 1
        report[:usersStats][user_key][:sessionsCount] += 1
        next
      end

      if user_mode
        case col
        when 2
          user_key = val
        when 3
          user_key = "#{user_key} #{val}"
          report[:usersStats][user_key] = {
            sessionsCount: 0,
            totalTime: 0,
            longestSession: 0,
            browsers: [],
            usedIE: false,
            alwaysUsedChrome: true,
            dates: []
          }
        end
      end

      if session_mode
        case col
        when 3
          report[:allBrowsers] << val.upcase!
          report[:uniqueBrowsersCount] << val
          report[:usersStats][user_key][:browsers] << val
          report[:usersStats][user_key][:usedIE] ||= val.match?(/INTERNET EXPLORER/)
          report[:usersStats][user_key][:alwaysUsedChrome] &&= val.match?(/CHROME/)
        when 4
          report[:usersStats][user_key][:totalTime] += val.to_i
          report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], val.to_i].max
        when 5
          report[:usersStats][user_key][:dates] << val
        end
      end
    end
  end

  report[:uniqueBrowsersCount] = report[:uniqueBrowsersCount].uniq!.size
  report[:allBrowsers] = report[:allBrowsers].sort!.uniq!.join(',')

  report[:usersStats].each_value do |user_hash|
    user_hash[:longestSession] = "#{user_hash[:longestSession]} min."
    user_hash[:totalTime] = "#{user_hash[:totalTime]} min."
    user_hash[:browsers] = user_hash[:browsers].sort!.join(', ')
    user_hash[:dates] = user_hash[:dates].sort!.reverse!
  end

  File.write('result.json', "#{report.to_json}\n")
end
