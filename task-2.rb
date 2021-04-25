# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'set'

USER = 'user'
SESSION = 'session'
USER_STATS = 'usersStats'

class User
  attr_reader :user_key, :sessions, :sessions_time, :sessions_max, :browsers, :sessions_dates, :sessions_count

  def initialize(attributes:)
    @user_key = "#{attributes[:first_name]} #{attributes[:last_name]}"
    @sessions_time = 0
    @sessions_count = 0
    @sessions_max = 0
    @browsers = []
    @sessions_dates = []
    @used_ie = false
    @always_used_chrome = true
  end

  def uniq_browsers
    @browsers.uniq
  end

  def used_ie?
    @used_ie
  end

  def always_used_chrome?
    @always_used_chrome
  end

  def process_session(session)
    @sessions_count += 1
    session_time = session[:time].to_i
    @sessions_time += session_time
    @sessions_max = @sessions_max > session_time ? @sessions_max : session_time
    @browsers << session[:browser]
    @always_used_chrome = false unless /CHROME/.match?(session[:browser])
    @used_ie = true if /INTERNET EXPLORER/.match?(session[:browser])
    @sessions_dates << session[:date]
  end
end

def parse_user(fields)
  {
    first_name: fields[2],
    last_name: fields[3]
  }
end

def parse_session(fields)
  {
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    report[USER_STATS][user.user_key] ||= {}
    report[USER_STATS][user.user_key].merge!(yield(user))
  end
end

def work(file_name)
  users_objects = []
  cols = []
  total_sessions = 0
  unique_browsers = SortedSet.new

  File.foreach(file_name, chomp: true) do |file_line|
    file_line.split(',') do |value|
      cols << value
    end

    case cols[0]
    when USER
      user = parse_user(cols)
      users_objects << User.new(attributes: user)
    when SESSION
      users_objects.last.process_session(parse_session(cols))
      total_sessions += 1
      unique_browsers.merge(users_objects.last.browsers)
    end
    cols.clear
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

  report = {}

  report[:totalUsers] = users_objects.count
  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:totalSessions] = total_sessions
  report[:allBrowsers] = unique_browsers.join(',')

  report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users_objects) do |user|
    { 'sessionsCount' => user.sessions_count,
      'totalTime' => "#{user.sessions_time} min.",
      'longestSession' => "#{user.sessions_max} min.",
      'browsers' => user.browsers.sort.join(', '),
      'usedIE' => user.used_ie?,
      'alwaysUsedChrome' => user.always_used_chrome?,
      'dates' => user.sessions_dates.sort.reverse }
  end

  File.write('result.json', "#{report.to_json}\n")
end
