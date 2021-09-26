# frozen_string_literal: true

require_relative 'user'
require 'json'
require 'date'

IE_REGEXP = /INTERNET EXPLORER/
CHROME_REGEXP = /CHROME/
USER = 'user'.freeze
SESSION = 'session'.freeze

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
  @report = { usersStats: {} }
end

def collect_data(filename)
  reset_user_stats

  File.read(filename).each_line(chomp: true) do |line|
    cols = line_to_ary(line)
    case cols[0]
    when USER
      calculate_current_user_stats if current_user
      User.create(attributes: parse_user(cols))
    when SESSION
      session = parse_session(cols)
      current_user.sessions << session
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
  @user_total_time += session[:time]
  @user_longest_session = session[:time] if @user_longest_session < session[:time]
  @user_browsers << upcased_browser
  @used_ie = true if upcased_browser.match?(IE_REGEXP)
  @used_only_chrome = false unless upcased_browser.match?(CHROME_REGEXP)
end

def calculate_total_stats
  @report[:totalUsers] = User.size
  @report[:uniqueBrowsersCount] = @unique_browsers.size
  @report[:totalSessions] = User.sum { |user| user.sessions.size }
  @report[:allBrowsers] = @unique_browsers.map(&:upcase).sort.join(',')
end

def calculate_current_user_stats
  @report[:usersStats][current_user.full_name] = current_user_stats
  reset_user_stats
end

def reset_user_stats
  @user_total_time = 0
  @user_longest_session = 0
  @user_browsers = []
  @used_ie = false
  @used_only_chrome = true
end

def current_user_stats
  {
    sessionsCount: current_user.sessions.size,
    totalTime: "#{@user_total_time} min.",
    longestSession: "#{@user_longest_session} min.",
    browsers: @user_browsers.sort.join(', '),
    usedIE: @used_ie,
    alwaysUsedChrome: @used_only_chrome,
    dates: current_user.sessions.map { |s| s[:date] }.sort.reverse
  }
end

def current_user
  User.last
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

def line_to_ary(line)
  line.split(',')
end
