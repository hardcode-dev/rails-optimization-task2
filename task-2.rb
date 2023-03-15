# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'
require 'set'


class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions: [])
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(fields)
  User.new(attributes: {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  })
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(user)
  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
  browsers = user.sessions.map { |s| s['browser'].upcase }

  @report['usersStats'] ||= {}
  @report['usersStats'][user_key] = {
    'sessionsCount' => user.sessions.count,
    'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.',
    'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.',
    'browsers' => browsers.sort.join(', '),
    'usedIE' => browsers.any? { |b| /INTERNET EXPLORER/.match?(b) },
    'alwaysUsedChrome' => browsers.all? { |b| /CHROME/.match?(b) },
    'dates' => user.sessions.map { |s| s['date'] }.sort.reverse
  }
end

def work(file_path: 'data.txt')
  current_user = nil
  total_users_count = 0
  total_sessions_count = 0
  unique_browsers = Set.new

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

  File.open('result.json', 'w') do |json|
    @report = {}

    File.foreach(file_path, chomp: true) do |line|
      cols = line.split(',')

      case cols[0]
      when 'user'
        collect_stats_from_users(current_user) if current_user
        current_user = parse_user(cols)
        total_users_count += 1
      when 'session'
        current_user.sessions << parse_session(cols)
        unique_browsers << cols[3].upcase
        total_sessions_count += 1
      end
    end

    collect_stats_from_users(current_user) if current_user

    @report['totalUsers'] = total_users_count
    @report['uniqueBrowsersCount'] = unique_browsers.count
    @report['totalSessions'] = total_sessions_count
    @report['allBrowsers'] = unique_browsers.sort.join(',')

    json.write(@report.to_json)
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
