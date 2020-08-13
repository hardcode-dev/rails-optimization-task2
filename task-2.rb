# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'

def work(filename: 'data.txt')
  @report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: [],
  }

  @user_stats = {}

  @user_key = nil

  @file = File.open('result.json', 'w')
  @file.write('{"usersStats":{')

  File.read(filename).split("\n") do |line|
    parse_line(line)
  end

  @report[:allBrowsers] = @report[:allBrowsers].sort.join(',')

  format_user_stats
  @file.write("\"#{@user_key}\":#{@user_stats.to_json}},#{@report.to_json[1..-1]}")
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
end

def parse_line(line)
  cols = line.split(',')
  if cols[0] == 'user'
    parse_user(cols)
  else
    parse_session(cols)
  end
end

def parse_user(cols)
  @report[:totalUsers] += 1
  if @user_key
    format_user_stats
    @file.write("\"#{@user_key}\":#{@user_stats.to_json},")
    @user_stats = nil
  end
  @user_key = "#{cols[2]} #{cols[3]}"
  @user_stats = {
    sessionsCount: 0, # Собираем количество сессий по пользователям
    totalTime: 0, # Собираем количество времени по пользователю
    longestSession: 0, # Выбираем самую длинную сессию пользователя
    browsers: [], # Браузеры пользователя через запятую
    usedIE: false, # Хоть раз использовал IE?
    alwaysUsedChrome: true, # Всегда использовал только Chrome?
    dates: [], # Даты сессий через запятую в обратном порядке в формате iso8601
  }
end

def parse_session(cols)
  @report[:totalSessions] += 1
  unless @report[:allBrowsers].include?(cols[3].upcase!)
    @report[:allBrowsers] << cols[3]
    @report[:uniqueBrowsersCount] += 1
  end
  @user_stats[:sessionsCount] += 1
  @user_stats[:totalTime] += cols[4].to_i
  @user_stats[:longestSession] = cols[4].to_i if @user_stats[:longestSession] < cols[4].to_i
  @user_stats[:browsers] << cols[3]
  @user_stats[:usedIE] ||= cols[3].start_with?('INTERNET EXPLORER')
  @user_stats[:alwaysUsedChrome] &&= cols[3].start_with?('CHROME')
  @user_stats[:dates] << cols[5].strip
end

def format_user_stats
  @user_stats[:totalTime] = @user_stats[:totalTime].to_s + ' min.'
  @user_stats[:longestSession] = @user_stats[:longestSession].to_s + ' min.'
  @user_stats[:browsers] = @user_stats[:browsers].sort.join(', ')
  @user_stats[:dates] = @user_stats[:dates].sort.reverse
end
