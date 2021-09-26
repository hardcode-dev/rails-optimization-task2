# frozen_string_literal: true

require_relative 'user'
require 'json'
require 'date'

def work(filename = 'data.txt')
  users = collect_data(filename)

  sessions = users.map(&:sessions).flatten
  report = {}
  report[:totalUsers] = users.size
  report[:uniqueBrowsersCount] = sessions.map { |s| s[:browser] }.uniq.count
  report[:totalSessions] = sessions.count
  report[:allBrowsers] = sessions.map { |s| s[:browser] }.map { |b| b.upcase }.uniq.sort.join(',')
  report[:usersStats] = {}

  # Собираем количество сессий по пользователям
  collect_stats_from_users(report, users) do |user|
    {
      sessionsCount: user.sessions.count,
      totalTime: user.sessions.map { |s| s[:time] }.map {|t| t.to_i}.sum.to_s + ' min.',
      longestSession: user.sessions.map { |s| s[:time] }.map {|t| t.to_i}.max.to_s + ' min.',
      browsers: user.sessions.map { |s| s[:browser] }.map { |b| b.upcase }.sort.join(', '),
      usedIE: user.sessions.map { |s| s[:browser] }.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      alwaysUsedChrome: user.sessions.map { |s| s[:browser] }.all? { |b| b.upcase =~ /CHROME/ },
      dates: user.sessions.map { |s| s[:date] }.sort.reverse
    }
  end

  File.write('result.json', "#{report.to_json}\n")
end

def collect_data(filename)
  users = []

  File.read(filename).each_line do |line|
    cols = line.rstrip.split(',')
    case cols[0]
    when 'user'
      users << User.new(attributes: parse_user(cols))
    when 'session'
      users.last.sessions << parse_session(cols)
    end
  end

  users
end

def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4]
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3],
    time: fields[4],
    date: fields[5]
  }
end

def collect_stats_from_users(report, users_objects, &block)
  users_objects.each do |user|
    user_key = "#{user.attributes[:first_name]} #{user.attributes[:last_name]}"
    report[:usersStats][user_key] = block.call(user)
  end
end
