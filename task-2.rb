# frozen_string_literal: true

require_relative 'user'
require 'json'
require 'date'

IE_REGEXP = /INTERNET EXPLORER/
CHROME_REGEXP = /CHROME/
USER = 'user'
SESSION = 'session'

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

def work(filename = 'data.txt')
  init_variables
  collect_data(filename)
  calculate_total_stats
  File.write('result.json', "#{@report.to_json}\n")
end

def init_variables
  @unique_browsers = []
  @report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: [],
    usersStats: {}
  }
end

def collect_data(filename)
  File.foreach(filename, chomp: true) do |line|
    cols = line.split(',')
    case cols[0]
    when USER
      calculate_current_user_stats if @current_user
      @current_user = User.new(attributes: parse_user(cols))
    when SESSION
      session = parse_session(cols)
      add_to_stats(session)
    end
  end

  calculate_current_user_stats
end

def add_to_stats(session)
  # For all users
  @unique_browsers << session[:browser] unless @unique_browsers.include?(session[:browser])

  # For current_user
  upcased_browser = session[:browser].upcase
  @current_user.sessions_count += 1
  @current_user.total_time += session[:time]
  @current_user.longest_session = session[:time] if @current_user.longest_session < session[:time]
  @current_user.browsers << upcased_browser
  @current_user.used_ie = true if upcased_browser.match?(IE_REGEXP)
  @current_user.used_only_chrome = false unless upcased_browser.match?(CHROME_REGEXP)
  @current_user.dates << session[:date]
end

def calculate_total_stats
  @report[:uniqueBrowsersCount] = @unique_browsers.size
  @report[:allBrowsers] = @unique_browsers.map(&:upcase).sort.join(',')
end

def calculate_current_user_stats
  @report[:totalUsers] += 1
  @report[:totalSessions] += @current_user.sessions_count
  @report[:usersStats][@current_user.full_name] = current_user_stats
end

def current_user_stats
  {
    sessionsCount: @current_user.sessions_count,
    totalTime: "#{@current_user.total_time} min.",
    longestSession: "#{@current_user.longest_session} min.",
    browsers: @current_user.browsers.sort.join(', '),
    usedIE: @current_user.used_ie,
    alwaysUsedChrome: @current_user.used_only_chrome,
    dates: @current_user.dates.sort!.reverse
  }
end

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4].to_i,
    date: fields[5]
  }
end
