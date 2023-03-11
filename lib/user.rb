require 'json'
require 'pry'
require 'date'

LINE_DIVIDER = ','.freeze

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

class StatCollector
  attr_reader :browsers, :users, :sessions_count, :users_count

  def initialize
    @browsers = Set.new
    @users = {}
    @users_count = 0
    @sessions_count = 0
  end

  def add_browser(browser)
    @browsers << browser
  end

  def add_user(user_id:, first_name:, last_name:, age:)
    @users[user_id] = {
      first_name: first_name,
      last_name: last_name,
      age: age,
      sessions_count: 0,
      browsers: [],
      sessions: []
    }
  end

  def add_user_browser(user_id, browser)
    @users[user_id][:browsers] << browser
  end

  def user_browsers(user_id)
    @users[user_id][:browsers]
  end

  def add_user_session(user_id, session)
    @users[user_id][:sessions].push(session)
  end

  def user_find_by_id(user_id)
    @users[user_id]
  end

  def user_sessions(user_id)
    @users[user_id][:sessions]
  end

  def sessions_grouped_by_user_id
    result = {}
    @users.map { |k, v| result[k] = v[:sessions] }
    result
  end

  def increment_user_sessions_count!(user_id)
    @users[user_id][:sessions_count] += 1
  end

  def increment_users_count!
    @users_count += 1
  end

  def increment_session_count!
    @sessions_count += 1
  end
end

def work(input_path:, output_path:)
  stat = StatCollector.new

  file_lines = File.read(input_path).split("\n")

  users = []
  sessions = []

  file_lines.each do |line|
    cols = line.split(LINE_DIVIDER)
    if cols[0] == 'user'
      stat.add_user(user_id: cols[1], first_name: cols[2], last_name: cols[3], age: cols[4])
      stat.increment_users_count!
    end
    if cols[0] == 'session'
      session = {
        user_id: cols[1],
        session_id: cols[2],
        browser: cols[3],
        time: cols[4],
        date: cols[5],
      }
      stat.add_user_session(session[:user_id], session)
      
      stat.increment_session_count!
      stat.increment_user_sessions_count!(session[:user_id])
      stat.add_user_browser(session[:user_id], session[:browser])

      # Подсчёт количества уникальных браузеров
      stat.add_browser(session[:browser])
    end
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

  report[:totalUsers] = stat.users_count

  report[:uniqueBrowsersCount] = stat.browsers.count
  report[:totalSessions] = stat.sessions_count
  report[:allBrowsers] = stat.browsers.map { |b| b.upcase }.sort.join(',')

  report[:usersStats] = {}

  stat.users.each do |user_id, attributes|
    user_key = "#{attributes[:first_name]} #{attributes[:last_name]}"

    report[:usersStats][user_key] ||= {
      sessionsCount: attributes[:sessions_count],
      totalTime: 0
    }

    total_time = 0
    longest_session_time = 0
    browsers = []
    used_ie = false
    always_used_chrome = true
    dates = []

    attributes[:sessions].each do |session|
      browser = session[:browser].upcase
      session_time = session[:time].to_i
      total_time += session_time
      longest_session_time = session_time if session_time > longest_session_time
      browsers << browser
      always_used_chrome = false if !browser.start_with?('CHROME')
      used_ie = true if browser.start_with?('INTERNET EXPLORER')
      dates << session[:date]
    end

    report[:usersStats][user_key][:totalTime] = "#{total_time} min."
    report[:usersStats][user_key][:longestSession] = "#{longest_session_time} min."
    report[:usersStats][user_key][:browsers] = browsers.sort!.join(', ')
    report[:usersStats][user_key][:usedIE] = used_ie
    report[:usersStats][user_key][:alwaysUsedChrome] = always_used_chrome
    report[:usersStats][user_key][:dates] = dates.sort! { |a, b| b <=> a }
  end

  File.write(output_path, "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end