# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

def format_user_stats(object)
  return unless object

  object[:totalTime] = object[:totalTime].to_s + ' min.'
  object[:longestSession] = object[:longestSession].to_s + ' min.'
  object[:browsers] = object[:browsers].sort.join(', ')
  object[:dates] = object[:dates].sort.reverse
end

def work(filename: 'data.txt', gc: true)
  GC.disable unless gc
  users = []
  sessions = []
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }

  user_key = nil

  File.read(filename).split("\n") do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      report[:totalUsers] += 1
      format_user_stats report[:usersStats][user_key]
      user_key = "#{cols[2]} #{cols[3]}"
      report[:usersStats][user_key] = {
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
      report[:usersStats][user_key][:sessionsCount] += 1
      report[:usersStats][user_key][:totalTime] += cols[4].to_i
      report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], cols[4].to_i].max
      report[:usersStats][user_key][:browsers] << cols[3]
      report[:usersStats][user_key][:usedIE] ||= cols[3].start_with?('INTERNET EXPLORER')
      report[:usersStats][user_key][:alwaysUsedChrome] &&= cols[3].start_with?('CHROME')
      report[:usersStats][user_key][:dates] << cols[5].strip
    end
  end

  report[:allBrowsers] = report[:allBrowsers].sort.join(',')

  format_user_stats report[:usersStats][user_key]

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

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

  GC.enable unless gc
end
