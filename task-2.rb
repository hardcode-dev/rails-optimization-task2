# frozen_string_literal: true

require 'json'

def parse_session!(fields)
  fields[3].upcase!
  fields[4] = fields[4].to_i
  fields[5].chomp!
  fields
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
    uniqueBrowsersCount: [],
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }
  user_key = nil

  File.foreach(filepath) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user = cols
      user_key = "#{user[2]} #{user[3]}"
      report[:totalUsers] += 1
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
    next unless cols[0] == 'session'

    session = parse_session!(cols)
    report[:totalSessions] += 1
    report[:allBrowsers] << session[3]
    report[:uniqueBrowsersCount] << session[3]

    report[:usersStats][user_key][:sessionsCount] += 1
    report[:usersStats][user_key][:totalTime] += session[4]
    report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], session[4]].max
    report[:usersStats][user_key][:browsers] << session[3]
    report[:usersStats][user_key][:usedIE] ||= session[3].match?(/INTERNET EXPLORER/)
    report[:usersStats][user_key][:alwaysUsedChrome] &&= session[3].match?(/CHROME/)
    report[:usersStats][user_key][:dates] << session[5]
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
