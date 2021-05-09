# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

class ParserOptimized
  class << self
    SEPARATOR = ','.freeze
    SPACE = ' '.freeze
    CACHED_DATES = { }

    def parse_date(date)
      CACHED_DATES[date] ||= Date.strptime(date, '%Y-%m-%d').iso8601
    end

    def parse_user(fields)
      parsed_result = {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4],
      }
    end

    def parse_session(fields)
      parsed_result = {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3],
        'time' => fields[4],
        'date' => parse_date(fields[5]),
      }
    end

    def collect_stats_from_users(report, users_objects, &block)
      users_objects.each do |user|
        user_key = "" << user.attributes['first_name'] << SPACE << user.attributes['last_name']
        report['usersStats'][user_key] ||= {}
        report['usersStats'][user_key] = report['usersStats'][user_key].merge!(block.call(user))
      end
    end

    def work(filename = 'data_large.txt')
      users = []
      users_sessions = {}

      File.foreach(filename) do |line|
        cols = line.split(SEPARATOR)
        users << parse_user(cols) if cols[0] == 'user'

        if cols[0] == 'session'
          session = parse_session(cols)
          users_sessions[session['user_id']] ||= []
          users_sessions[session['user_id']] << session
        end
      end

      sessions = users_sessions.values.flatten
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
          .join(SEPARATOR)

      # Статистика по пользователям
      users_objects = []

      users.each do |user|
        attributes = user
        user_sessions = users_sessions[user['id']]
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
        { 'dates' => user.sessions.map{ |s| s['date'] }.sort.reverse }
      end

      File.write('result.json', "#{report.to_json}\n")
      puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    end
  end
end
