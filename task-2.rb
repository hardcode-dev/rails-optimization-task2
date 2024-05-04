# frozen_string_literal: true

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

def parse_user(user)
  regexp = /(\w+),(\w+),(\w+),(\w+),(\w+)(\n)/
  fields = regexp.match(user)

  {
    'id' => fields[2],
    'first_name' => fields[3],
    'last_name' => fields[4],
    'age' => fields[5]
  }
end

def parse_session(session)
  regexp =  /(\w+),(\w+),(\w+),([a-zA-Z0-9_ ]+),(\w+),([0-9-]+)(\n)/
  fields = regexp.match(session)

  {
    'user_id' => fields[2],
    'session_id' => fields[3],
    'browser' => fields[4].upcase,
    'time' => fields[5],
    'date' => fields[6]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
    report['usersStats'][user_key] ||= {}
    report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
  end
end

def build_user_hash(session, sessions_users, user_uniq_browsers, uniq_browsers)
  if sessions_users[session['user_id']].nil?
    sessions_users[session['user_id']] = [session]
  else
    sessions_users[session['user_id']] << session
  end

  user_uniq_browsers[session['browser']] = nil if user_uniq_browsers[session['browser']].nil?
  uniq_browsers[session['browser']] = nil if uniq_browsers[session['browser']].nil?
end

USER = 'user'

def user_file_report(string)
  @user_report.write(string)
end

def call(user_sessions, report, last_line = false)
  user_report, report = processor(user_sessions, report)

  if last_line
    string = "#{user_report["usersStats"].to_json[1..-2]}"
    # File.write('user_reports.txt', "#{user_report["usersStats"].to_json[1..-2]}", mode: 'a')
    user_file_report(string)
  else
    string = "#{user_report["usersStats"].to_json[1..-2]},"
    user_file_report(string)
  end
  report
end

def work(file_path = 'data.txt')
  File.write('result.json', '')
  File.write('user_reports.txt', '')
  @user_report = File.open('user_reports.txt', 'a')

  is_user = false
  user_sessions = []

  report = { 'totalUsers' => 0,
             'uniqueBrowsersCount' => 0,
             'totalSessions' => 0,
             'allBrowsers' => '',
              'uniq_browsers' => {} }

  File.foreach(file_path) do |line|
    if line.start_with? USER
      report = call(user_sessions, report) if is_user

      user_sessions = [] if is_user # clear sessions for next user
      user_sessions << line
      is_user = true # collect all session for first user
    else
      user_sessions << line
    end
  end

  report = call(user_sessions, report, true) if is_user # collect stats for last user

  all_browsers = report['uniq_browsers'].keys
  report['uniqueBrowsersCount'] = all_browsers.count
  report['allBrowsers'] = all_browsers.sort.join(',')
  report.delete('uniq_browsers')

  @user_report.close

  File.write('result.json', "#{report.to_json[..-2]},\"usersStats\":{")

  File.open("user_reports.txt", "r") do |f|
    f.each_line do |line|
      File.write('result.json', line, mode: 'a')
    end
  end
  File.write('result.json', "}}", mode: 'a')


  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

def processor(lines, report)
  file_lines = lines

  user = nil
  sessions = []
  sessions_users = {}
  user_uniq_browsers = {}

  file_lines.each do |line|
    is_user = line.start_with? USER

    if is_user
      user = parse_user(line)
    else
      session = parse_session(line)
      sessions << session
      build_user_hash(session, sessions_users, user_uniq_browsers, report['uniq_browsers'])
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


  report['totalUsers'] += 1
  report['totalSessions'] += sessions_users.values.first.count

  # Статистика по пользователю
  users_objects = []
  attributes = user
  user_sessions = sessions_users[user['id']]
  user_object = User.new(attributes:, sessions: user_sessions)
  users_objects << user_object


  user_report = {}
  user_report['usersStats'] = {}

  collect_stats_from_users(user_report, users_objects) do |user|
    # Собираем количество сессий по пользователям
    { 'sessionsCount' => user.sessions.count,
      # Собираем количество времени по пользователям
      'totalTime' => user.sessions.map { |s| s['time'] }.map(&:to_i).sum.to_s + ' min.',
      # Выбираем самую длинную сессию пользователя
      'longestSession' => user.sessions.map { |s| s['time'] }.map(&:to_i).max.to_s + ' min.',
      # Браузеры пользователя через запятую
      'browsers' => user.sessions.map { |s| s['browser'] }.sort.join(', '),
      # Хоть раз использовал IE?
      'usedIE' => user.sessions.map { |s| s['browser'] }.any? { |b| b =~ /INTERNET EXPLORER/ },
      # Всегда использовал только Chrome?
      'alwaysUsedChrome' => user.sessions.map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ },
      # Даты сессий через запятую в обратном порядке в формате iso8601
      'dates' => user.sessions.map { |s| s['date'] }.sort.reverse }
  end

  [user_report, report]

  # File.write('result.json', "#{report.to_json}\n", mode: 'a')
  # puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
  # GC.start(full_mark: true, immediate_sweep: true)
end

work('data_large.txt')
