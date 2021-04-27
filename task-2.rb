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

  def used_ie?
    @used_ie
  end

  def always_used_chrome?
    @always_used_chrome
  end

  def process_session(attributes:)
    @sessions_count += 1
    session_time = attributes[:time].to_i
    @sessions_time += session_time
    @sessions_max = @sessions_max > session_time ? @sessions_max : session_time
    @browsers << attributes[:browser].upcase
    @always_used_chrome = false unless /CHROME/.match?(@browsers.last)
    @used_ie = true if /INTERNET EXPLORER/.match?(@browsers.last)
    @sessions_dates << attributes[:date]
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
    browser: fields[3].upcase,
    time: fields[4],
    date: fields[5]
  }
end

class Report
  attr_accessor :total_sessions, :unique_browsers

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

  def initialize
    @file = File.open('result.json', 'w')
    @file.write('{"usersStats":{')
    @total_sessions = 0
    @total_users = 0
    @unique_browsers = SortedSet.new
  end

  def collect_stats_from_user(user:, last: false)
    @total_users += 1
    @file.write("#{user.user_key.to_json}:")
    user_report =
      { sessionsCount: user.sessions_count,
        totalTime: "#{user.sessions_time} min.",
        longestSession: "#{user.sessions_max} min.",
        browsers: user.browsers.sort.join(', '),
        usedIE: user.used_ie?,
        alwaysUsedChrome: user.always_used_chrome?,
        dates: user.sessions_dates.sort.reverse }
    @file.write(user_report.to_json)
    @file.write(last ? '},' : ',')
    finalize if last
  end

  private

  def finalize
    report = {}
    report[:totalUsers] = @total_users
    report[:uniqueBrowsersCount] = @unique_browsers.count
    report[:totalSessions] = @total_sessions
    report[:allBrowsers] = @unique_browsers.join(',')
    @file.write("#{report.to_json.delete('{}')}}\n")
    @file.close
  end
end

def work(file_name)
  user = nil
  report = Report.new

  File.foreach(file_name, chomp: true) do |file_line|
    cols = file_line.split(',')

    case cols[0]
    when USER
      report.collect_stats_from_user(user: user) if user
      user = User.new(attributes: parse_user(cols))
    when SESSION
      user.process_session(attributes: parse_session(cols))
      report.total_sessions += 1
      report.unique_browsers.merge(user.browsers)
    end
  end
  report.collect_stats_from_user(user: user, last: true) if user
end
