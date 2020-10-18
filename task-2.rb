# frozen_string_literal: true

# Deoptimized version of homework task

require 'json'
require 'date'
require 'csv'
require 'set'
require 'byebug'

class User
  attr_reader :attributes, :sessions, :browsers
  attr_accessor :browsers, :session_durations, :session_dates

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
    @sessions_count = 0
    @sessions_total_time = 0
    @session_durations = []
    @session_dates = []
    @longest_session = 0
    @used_ie = false
    @chrome_fan = true
    @browsers = []
  end

  def key
    @key ||= "#{attributes['first_name']} #{attributes['last_name']}"
  end

  def sessions_total_time
    "#{session_durations.sum} min."
  end

  def longest_session
    "#{session_durations.max} min."
  end

  def used_ie?
    browsers.any? { |b| b.start_with?('INTERNET EXPLORER') }
  end

  def chrome_fan?
    (sessions_count.positive? && browsers.all? { |b| b.start_with?('CHROME') })
  end

  def sessions_count
    @sessions.length
  end

  def user_stats
    { 'sessionsCount' => sessions_count,
      'totalTime' => sessions_total_time,
      'longestSession' => longest_session,
      'browsers' => browsers.sort.join(', '),
      'usedIE' => used_ie?,
      'alwaysUsedChrome' => chrome_fan?,
      'dates' => session_dates.sort.reverse }
  end
end

def parse_user(fields)
  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4]
  }
end

def parse_session(fields)
  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5]
  }
end

def collect_stats_from_users(report, users_objects)
  users_objects.each do |user|
    user_key = user.key
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(yield(user))
  end
end

def report_user(prev_user, users_stats)
  users_stats[prev_user.key] ||= {}
  users_stats[prev_user.key] = users_stats[prev_user.key].merge(prev_user.user_stats)
end

def work(file_path = 'data_large.txt')
  # file_lines = File.read(file_path).split("\n")
  # result_file = 'result.json'
  sessions_count = 0
  users_count = 0
  browsers = SortedSet.new
  browsers_count = 0
  report = {}
  users = {}
  users_stats = {}
  prev_user = nil
  # File.open(result_file, 'a') do |result|
  CSV.foreach(file_path).each do |fields|
    if fields[0] == 'user'
      user = User.new(attributes: parse_user(fields), sessions: [])
      users[fields[1]] = user
      users_count += 1
      unless prev_user.eql?(user)
        # form report for previously imported user
        if prev_user
          report_user(prev_user, users_stats)
          users.delete([prev_user.attributes['id']])
        end
        prev_user = user
      end
    end

    next unless fields[0] == 'session'

    user = users[fields[1]]
    user.sessions << parse_session(fields)
    user.browsers << fields[3].upcase
    browsers << fields[3].upcase
    browsers_count += 1
    user.session_durations << fields[4].to_i
    user.session_dates << fields[5]
    sessions_count += 1
  end
  report_user(prev_user, users_stats)
  # end
  # sessions << parse_session(cols) if cols[0] == 'session'

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

  report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  # # uniqueBrowsers = []
  # sessions.each do |session|
  #   browser = session['browser']
  #   uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
  # end

  report['uniqueBrowsersCount'] = browsers.count

  report['totalSessions'] = sessions_count

  report['allBrowsers'] = browsers.to_a.join(',')

  # Статистика по пользователям
  # users_objects = []
  #
  # users.each do |_id, user|
  #
  #   users_objects << user
  # end
  #
  # report['usersStats'] = {}
  #
  # # Собираем количество сессий по пользователям
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'sessionsCount' => user.sessions.count }
  # end
  #
  # # Собираем количество времени по пользователям
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.' }
  # end
  #
  # # Выбираем самую длинную сессию пользователя
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.' }
  # end
  #
  # # Браузеры пользователя через запятую
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'browsers' => user.sessions.map { |s| s['browser'] }.map(&:upcase).sort.join(', ') }
  # end
  #
  # # Хоть раз использовал IE?
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  # end
  #
  # # Всегда использовал только Chrome?
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b.upcase =~ /CHROME/ } }
  # end
  #
  # # Даты сессий через запятую в обратном порядке в формате iso8601
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'dates' => user.sessions.map { |s| s['date'] }.map.sort.reverse }
  # end
  report['usersStats'] = users_stats

  File.write('result.json', "#{report.to_json}\n")
  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

# work
