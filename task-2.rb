# frozen_string_literal: true

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

def write_stats_from_user(result, user)
  sessions = user.sessions
  browsers = sessions.map { |s| s[:browser].upcase }.sort
  time = sessions.map { |s| s[:time].to_i }
  report = {
    'sessionsCount' => sessions.count,
    'totalTime' => time.sum.to_s + ' min.',
    'longestSession' => time.max.to_s + ' min.',
    'browsers' => browsers.join(', '),
    'usedIE' => browsers.any? { |b| b.start_with?('INTERNET EXPLORER') },
    'alwaysUsedChrome' => browsers.all? { |b| b.start_with?('CHROME') },
    'alwaysUsedChrome' => browsers.all? { |b| b.start_with?('CHROME') },
    'dates' => sessions.map { |s| s[:date] }.sort.reverse
  }
  result.write("\"#{user.attributes[:first_name]} #{user.attributes[:last_name]}\":#{report.to_json}")
end

def work(file, disable_gc: false)
  GC.disable if disable_gc
  File.open('result.json', 'w') do |result|
    result.write('{"usersStats":{')

    report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: nil }
    allBrowsers = []
    user = nil

    File.open('data/' + file).each do |line|
      index = 0
      mode = nil
      attrs = {}
      session = {}
      line.strip.split(',') do |field|
        case mode
        when 'user'
          case index
          when 1
            attrs[:id] = field
          when 2
            attrs[:first_name] = field
          when 3
            attrs[:last_name] = field
          when 4
            attrs[:age] = field
            write_stats_from_user(result, user) unless user.nil?
            result.write(',') unless user.nil?
            user = User.new(attributes: attrs, sessions: [])
            report[:totalUsers] += 1
          end
        when 'session'
          case index
          when 1
            session[:user_id] = field
          when 2
            session[:session_id] = field
          when 3
            session[:browser] = field
            allBrowsers << field unless allBrowsers.include?(field)
          when 4
            session[:time] = field
          when 5
            session[:date] = field
            user.sessions << session
            report[:totalSessions] += 1
          end
        when nil
          mode = field
        end
        index += 1
      end
    end
    write_stats_from_user(result, user) unless user.nil?

    # Подсчёт количества уникальных браузеров
    report[:uniqueBrowsersCount] = allBrowsers.count
    report[:allBrowsers] = allBrowsers.sort.join(',').upcase

    result.write("},#{report.to_json[1..-1]}")
  end
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
