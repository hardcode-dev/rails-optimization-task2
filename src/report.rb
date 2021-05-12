# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'ruby-progressbar'
require 'set'
require_relative 'user'

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5].chomp!
  }
end

def work(file_name, lines_count = nil, progressbar_enabled = false)
  file_lines = File.read(file_name).split("\n") if progressbar_enabled

  total_users = 0
  total_sessions = 0
  all_browsers = Set.new
  sessions = []
  user = nil

  progressbar = ProgressBar.create(total: file_lines.count, format: '%a, %J, %E %B') if progressbar_enabled

  report_file = File.open('result.json', 'w')
  report_file.write('{"usersStats":{')
  i = 0
  File.foreach(file_name) do |line|
    i += 1
    break if lines_count && i == lines_count

    progressbar.increment if progressbar_enabled

    cols = line.split(',')
    if cols[0] == 'user'
      if user
        user.calculate_parameters(sessions)
        report_file.write("\"#{user.key}\":")
        report_file.write(user.stats.to_json)
        report_file.write(',')
      end
      user = User.new("#{cols[2]} #{cols[3]}")
      sessions = []
      total_users += 1
    end

    if cols[0] == 'session'
      session = parse_session(cols)
      sessions.push(session)
      total_sessions += 1
      all_browsers.add(session['browser'])
    end
  end

  if user
    user.calculate_parameters(sessions)
    report_file.write("\"#{user.key}\":")
    report_file.write(user.stats.to_json)
    report_file.write('},')
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

  report = {
    totalUsers: total_users,
    uniqueBrowsersCount: all_browsers.count,
    totalSessions: total_sessions,
    allBrowsers: all_browsers.to_a.sort!.join(',')
  }

  report_file.write("#{report.to_json[1..-1]}\n")
  report_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
