# frozen_string_literal: true

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
    'date' => fields[5],
  }
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
      if report[:usersStats][user_key]
        report[:usersStats][user_key][:totalTime] = report[:usersStats][user_key][:totalTime].to_s + ' min.'
        report[:usersStats][user_key][:longestSession] = report[:usersStats][user_key][:longestSession].to_s + ' min.'
        report[:usersStats][user_key][:browsers] = report[:usersStats][user_key][:browsers].sort.join(', ')
        report[:usersStats][user_key][:dates] = report[:usersStats][user_key][:dates].sort.reverse
      end
      user = parse_user(line)
      user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
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
      session = parse_session(line)
      report[:totalSessions] += 1
      unless report[:allBrowsers].include?(session['browser'].upcase)
        report[:allBrowsers] << session['browser'].upcase
        report[:uniqueBrowsersCount] += 1
      end
      report[:usersStats][user_key][:sessionsCount] += 1
      report[:usersStats][user_key][:totalTime] += session['time'].to_i
      report[:usersStats][user_key][:longestSession] = [report[:usersStats][user_key][:longestSession], session['time'].to_i].max
      report[:usersStats][user_key][:browsers] << session['browser'].upcase
      report[:usersStats][user_key][:usedIE] ||= session['browser'].upcase.match?(/INTERNET EXPLORER/)
      report[:usersStats][user_key][:alwaysUsedChrome] &&= session['browser'].upcase.match?(/CHROME/)
      report[:usersStats][user_key][:dates] << session['date'].strip
    end
  end

  report[:allBrowsers] = report[:allBrowsers].sort.join(',')

  if report[:usersStats][user_key]
    report[:usersStats][user_key][:totalTime] = report[:usersStats][user_key][:totalTime].to_s + ' min.'
    report[:usersStats][user_key][:longestSession] = report[:usersStats][user_key][:longestSession].to_s + ' min.'
    report[:usersStats][user_key][:browsers] = report[:usersStats][user_key][:browsers].sort.join(', ')
    report[:usersStats][user_key][:dates] = report[:usersStats][user_key][:dates].sort.reverse
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

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

  GC.enable unless gc
end
