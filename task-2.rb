# frozen_string_literal: true

require 'json'
require 'date'

def parse_user(fields)
  parsed_result = {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(fields)
  parsed_result = {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5].chomp
  }
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
      user = parse_user(cols)
      user_key = "#{user[:first_name]}" + ' ' + "#{user[:last_name]}"
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

    session = parse_session(cols)
    report[:totalSessions] += 1
    report[:allBrowsers] << session[:browser]
    report[:uniqueBrowsersCount] << session[:browser]

    report[:usersStats][user_key][:sessionsCount] += 1
    report[:usersStats][user_key][:totalTime] += session[:time]
    report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], session[:time]].max
    report[:usersStats][user_key][:browsers] << session[:browser]
    report[:usersStats][user_key][:usedIE] ||= session[:browser].match?(/INTERNET EXPLORER/)
    report[:usersStats][user_key][:alwaysUsedChrome] &&= session[:browser].match?(/CHROME/)
    report[:usersStats][user_key][:dates] << session[:date]
  end

  report[:uniqueBrowsersCount] = report[:uniqueBrowsersCount].uniq.size
  report[:allBrowsers] = report[:allBrowsers].sort.uniq.join(',')

  report[:usersStats].each_value do |user_hash|
    user_hash[:longestSession] = "#{user_hash[:longestSession]} min."
    user_hash[:totalTime] = "#{user_hash[:totalTime]} min."
    user_hash[:browsers] = user_hash[:browsers].sort.join(', ')
    user_hash[:dates] = user_hash[:dates].sort!.reverse!
  end

  File.write('result.json', "#{report.to_json}\n")
end
