# frozen_string_literal: true

require_relative 'user'
require_relative 'oj_helper'
require 'json'
require 'date'
require 'set'
require 'oj'

include OjHelper

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
  File.open('result.json', 'w+') do |file|
    init_variables
    init_stream(file)
    push_report_to_stream(filename)
  end
end

private

def init_variables
  @unique_browsers = Set.new
  @users_count = 0
  @sessions_count = 0
  @current_user = nil
end

def push_report_to_stream(filename)
  push_object do
    push_key('usersStats')
    push_object do
      push_users_stats(filename)
    end
    push_total_stats
  end

  flush
end

def push_users_stats(filename)
  File.foreach(filename, chomp: true) do |line|
    cols = line.split(',')
    case cols[0]
    when USER
      # Do not push first time
      push_current_user_stats if @current_user
      @current_user = User.new(attributes: parse_user(cols))
    when SESSION
      session = parse_session(cols)
      add_to_stats(session)
    end
  end

  # Push last user
  push_current_user_stats
end

def add_to_stats(session)
  upcased_browser = session[:browser].upcase

  # For all users
  @unique_browsers << upcased_browser

  # For current_user
  @current_user.sessions_count += 1
  @current_user.total_time += session[:time]
  @current_user.longest_session = session[:time] if @current_user.longest_session < session[:time]
  @current_user.browsers << upcased_browser
  @current_user.used_ie = true if upcased_browser.match?(IE_REGEXP)
  @current_user.used_only_chrome = false unless upcased_browser.match?(CHROME_REGEXP)
  @current_user.dates << session[:date]
end

def push_total_stats
  push_pair('totalUsers', @users_count)
  push_pair('totalSessions', @sessions_count)
  push_pair('uniqueBrowsersCount', @unique_browsers.size)
  push_pair('allBrowsers', @unique_browsers.sort.join(','))
end

def push_current_user_stats
  @users_count += 1
  @sessions_count += @current_user.sessions_count

  push_key(@current_user.full_name)
  push_object do
    push_pair('sessionsCount', @current_user.sessions_count)
    push_pair('totalTime', "#{@current_user.total_time} min.")
    push_pair('longestSession', "#{@current_user.longest_session} min.")
    push_pair('browsers', @current_user.browsers.sort.join(', '))
    push_pair('usedIE', @current_user.used_ie)
    push_pair('alwaysUsedChrome', @current_user.used_only_chrome)
    push_pair('dates', @current_user.dates.sort!.reverse)
  end
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
