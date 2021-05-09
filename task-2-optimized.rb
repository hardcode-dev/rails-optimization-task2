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
    ID = :id
    FIRST_NAME = :first_name
    LAST_NAME = :last_name
    AGE = :age
    USER_ID = :user_id
    SESSION_ID = :session_id
    BROWSER = :browser
    TIME = :time
    DATE = :date

    # row types
    SESSION = 'session'.freeze
    USER = 'user'.freeze

    DATE_FORMAT = '%Y-%m-%d'

    def parse_date(date)
      CACHED_DATES[date] ||= Date.strptime(date, DATE_FORMAT).iso8601
    end

    def parse_user(line)
      _, id, first_name, last_name, age = line.split(SEPARATOR)
      {
        ID => id.to_i,
        FIRST_NAME => first_name,
        LAST_NAME => last_name,
        AGE => age.to_i,
      }
    end

    def parse_session(line)
      _, user_id, session_id, browser, time, date = line.split(SEPARATOR)
      {
        USER_ID => user_id.to_i,
        SESSION_ID => session_id.to_i,
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

    CHROME = 'CHROME'

    INTERNET_EXPLORER = 'INTERNET EXPLORER'

    BROWSER_SEPARATOR = ', '

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
      # Собираем количество времени по пользователям
      # Выбираем самую длинную сессию пользователя
      # Браузеры пользователя через запятую
      # Хоть раз использовал IE?
      # Всегда использовал только Chrome?
      # Даты сессий через запятую в обратном порядке в формате iso8601
      collect_stats_from_users(report, users_objects) do |user|
        sessions_times = user.sessions.map {|s| s[TIME] }
        browsers = user.sessions.map { |b| b[BROWSER] }
        {
          SESSION_COUNT => user.sessions.count,
          TOTAL_TIME => "#{sessions_times.sum}#{MIN_POSTFIX}",
          LONGEST_SESSION => "#{sessions_times.max}#{MIN_POSTFIX}",
          BROWSERS => browsers.sort.join(BROWSER_SEPARATOR),
          USED_IE => browsers.any? { |b| b.start_with? INTERNET_EXPLORER },
          ALWAYS_USED_CHROME => browsers.all? { |b| b.start_with? CHROME },
          DATES => user.sessions.map{ |s| s[DATE] }.sort.reverse
        }
      end

      File.write('result.json', "#{report.to_json}\n")
      puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    end
  end
end
