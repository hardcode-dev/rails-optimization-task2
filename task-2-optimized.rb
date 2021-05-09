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

    # Fields name
    ID = 'id'.freeze
    FIRST_NAME = 'first_name'.freeze
    LAST_NAME = 'last_name'.freeze
    AGE = 'age'.freeze
    USER_ID = 'user_id'.freeze
    SESSION_ID = 'session_id'.freeze
    BROWSER = 'browser'.freeze
    TIME = 'time'.freeze
    DATE = 'date'.freeze

    # row types
    SESSION = 'session'.freeze
    USER = 'user'.freeze

    def parse_date(date)
      CACHED_DATES[date] ||= Date.strptime(date, '%Y-%m-%d').iso8601
    end

    def parse_user(line)
      _, id, first_name, last_name, age = line.split(SEPARATOR)
      {
        ID => id,
        FIRST_NAME => first_name,
        LAST_NAME => last_name,
        AGE => age,
      }
    end

    def parse_session(line)
      _, user_id, session_id, browser, time, date = line.split(SEPARATOR)
      {
        USER_ID => user_id,
        SESSION_ID => session_id,
        BROWSER => browser.upcase,
        TIME => time.to_i,
        DATE => parse_date(date),
      }
    end


    def collect_stats_from_users(report, users_objects, &block)
      users_objects.each do |user|
        user_key = "#{user.attributes[FIRST_NAME]}#{SPACE}#{user.attributes[LAST_NAME]}"
        report[USER_STATS][user_key] ||= {}
        report[USER_STATS][user_key] = report[USER_STATS][user_key].merge!(block.call(user))
      end
    end

    # Report fields
    USER_STATS = 'usersStats'.freeze
    SESSION_COUNT = 'sessionsCount'.freeze
    TOTAL_TIME = 'totalTime'.freeze
    LONGEST_SESSION = 'longestSession'.freeze
    BROWSERS = 'browsers'.freeze
    USED_IE = 'usedIE'.freeze
    ALWAYS_USED_CHROME = 'alwaysUsedChrome'.freeze
    DATES = 'dates'.freeze

    MIN_POSTFIX = ' min.'

    def work(filename = 'data_large.txt')
      users = []
      users_sessions = {}

      File.foreach(filename) do |line|
        users << parse_user(line) if line.start_with? USER

        if line.start_with? SESSION
          session = parse_session(line)
          users_sessions[session[USER_ID]] ||= []
          users_sessions[session[USER_ID]] << session
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
        browser = session[BROWSER]
        uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
      end

      report['uniqueBrowsersCount'] = uniqueBrowsers.count

      report['totalSessions'] = sessions.count

      report['allBrowsers'] =
        sessions
          .map { |s| s[BROWSER] }
          .map { |b| b.upcase }
          .sort
          .uniq
          .join(SEPARATOR)

      # Статистика по пользователям
      users_objects = []

      users.each do |user|
        attributes = user
        user_sessions = users_sessions[user[ID]]
        user_object = User.new(attributes: attributes, sessions: user_sessions)
        users_objects << user_object
      end

      report[USER_STATS] = {}

      # Собираем количество сессий по пользователям
      collect_stats_from_users(report, users_objects) do |user|
        { SESSION_COUNT => user.sessions.count }
      end

      # Собираем количество времени по пользователям
      collect_stats_from_users(report, users_objects) do |user|
        { TOTAL_TIME => "#{user.sessions.map {|s| s[TIME] }.sum}#{MIN_POSTFIX}" }
      end

      # Выбираем самую длинную сессию пользователя
      collect_stats_from_users(report, users_objects) do |user|
        { LONGEST_SESSION => "#{user.sessions.map {|s| s[TIME] }.max}#{MIN_POSTFIX}" }
      end

      # Браузеры пользователя через запятую
      collect_stats_from_users(report, users_objects) do |user|
        { BROWSERS => user.sessions.map {|b| b[BROWSER]}.sort.join(', ') }
      end

      # Хоть раз использовал IE?
      collect_stats_from_users(report, users_objects) do |user|
        { USED_IE => user.sessions.map {|b| b[BROWSER]}.any? { |b| b =~ /INTERNET EXPLORER/ } }
      end

      # Всегда использовал только Chrome?
      collect_stats_from_users(report, users_objects) do |user|
        { ALWAYS_USED_CHROME => user.sessions.map {|b| b[BROWSER]}.all? { |b| b =~ /CHROME/ } }
      end

      # Даты сессий через запятую в обратном порядке в формате iso8601
      collect_stats_from_users(report, users_objects) do |user|
        { DATES => user.sessions.map{ |s| s[DATE] }.sort.reverse }
      end

      File.write('result.json', "#{report.to_json}\n")
      puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    end
  end
end
