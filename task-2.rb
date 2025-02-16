require 'json'
require 'date'
require_relative 'memory_watcher'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

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

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge!(block.call(user))
  end
end

def work(file_path = 'data.txt', disable_gc = false, memory_watcher = false)
  if memory_watcher
    memory_watcher = MemoryWatcher.new(70)
    memory_watcher.start
  end

  GC.disable if disable_gc

  file_lines = File.read(file_path).split("\n")

  users = []
  sessions = []
  begin
    file_lines.each do |line|
      case
      when line.start_with?('user,')
        users << parse_user(line)
      when line.start_with?('session,')
        sessions << parse_session(line)
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

    report[:totalUsers] = users.count

    # Подсчёт количества уникальных браузеров
    uniqueBrowsers = []
    sessions.each do |session|
      browser = session['browser']
      uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
    end

    report['uniqueBrowsersCount'] = uniqueBrowsers.count

    report['totalSessions'] = sessions.count

    report['allBrowsers'] =
      sessions
        .map { |s| s['browser'] }
        .map { |b| b.upcase }
        .sort
        .uniq
        .join(',')

    # Статистика по пользователям
    users_objects = []

    sessions_by_user = sessions.group_by { |session| session['user_id'] }

    users.each do |user|
      attributes = user
      user_sessions = sessions_by_user[user['id']] || []
      user_object = User.new(attributes: attributes, sessions: user_sessions)
      users_objects << user_object
    end

    report['usersStats'] = {}

    # Собираем количество сессий по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'sessionsCount' => user.sessions.count }
    end

    # Собираем количество времени по пользователям
    collect_stats_from_users(report, users_objects) do |user|
      { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
    end

    # Выбираем самую длинную сессию пользователя
    collect_stats_from_users(report, users_objects) do |user|
      { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
    end

    # Браузеры пользователя через запятую
    collect_stats_from_users(report, users_objects) do |user|
      { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
    end

    # Хоть раз использовал IE?
    collect_stats_from_users(report, users_objects) do |user|
      { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
    end

    # Всегда использовал только Chrome?
    collect_stats_from_users(report, users_objects) do |user|
      { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
    end

    # Даты сессий через запятую в обратном порядке в формате iso8601
    collect_stats_from_users(report, users_objects) do |user|
      { 'dates' => user.sessions.map{|s| s['date']}.sort.reverse }
    end

    File.write('result.json', "#{report.to_json}\n")
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  ensure
    memory_watcher.stop if memory_watcher
  end
end
