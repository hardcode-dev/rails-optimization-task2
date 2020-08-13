# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'

def format_user_stats(object)
  object[:totalTime] = object[:totalTime].to_s + ' min.'
  object[:longestSession] = object[:longestSession].to_s + ' min.'
  object[:browsers] = object[:browsers].sort.join(', ')
  object[:dates] = object[:dates].sort.reverse
end

def work(filename: 'data.txt', gc: true)
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: [],
  }

  user_stats = {}

  user_key = nil

  @file = File.open('result.json', 'w')
  @file.write('{"usersStats":{')

  File.read(filename).split("\n") do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      report[:totalUsers] += 1
      if user_key
        format_user_stats user_stats
        @file.write("\"#{user_key}\":#{user_stats.to_json},")
      end
      user_key = "#{cols[2]} #{cols[3]}"
      user_stats = {
        sessionsCount: 0, # Собираем количество сессий по пользователям
        totalTime: 0, # Собираем количество времени по пользователю
        longestSession: 0, # Выбираем самую длинную сессию пользователя
        browsers: [], # Браузеры пользователя через запятую
        usedIE: false, # Хоть раз использовал IE?
        alwaysUsedChrome: true, # Всегда использовал только Chrome?
        dates: [], # Даты сессий через запятую в обратном порядке в формате iso8601
      }

    elsif cols[0] == 'session'
      report[:totalSessions] += 1
      unless report[:allBrowsers].include?(cols[3].upcase!)
        report[:allBrowsers] << cols[3]
        report[:uniqueBrowsersCount] += 1
      end
      user_stats[:sessionsCount] += 1
      user_stats[:totalTime] += cols[4].to_i
      user_stats[:longestSession] = [user_stats[:longestSession], cols[4].to_i].max
      user_stats[:browsers] << cols[3]
      user_stats[:usedIE] ||= cols[3].start_with?('INTERNET EXPLORER')
      user_stats[:alwaysUsedChrome] &&= cols[3].start_with?('CHROME')
      user_stats[:dates] << cols[5].strip
    end
  end

  report[:allBrowsers] = report[:allBrowsers].sort.join(',')

  format_user_stats user_stats
  @file.write("\"#{user_key}\":#{user_stats.to_json}},#{report.to_json[1..-1]}")
  @file.close

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

  # File.write('result.json', "#{report.to_json}\n")
end
