# Deoptimized version of homework task
# frozen_string_literal: true
require 'json'
require 'pry'
require 'date'
require 'set'

USER_COLUMNS = %w[_ id first_name last_name age].freeze
SESSION_COLUMNS = %w[_ user_id session_id browser time date].freeze

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(line)
  index = -1
  result = {}

  line.split(',') do |value|
    index += 1
    next if index == 0

    result[USER_COLUMNS[index]] = value
  end
  result
end

def parse_session(line)
  index = -1
  result = {}
  line.split(',') do |value|
    index += 1
    next if index == 0

    # upcase for browser field
    if index == 3
      result[SESSION_COLUMNS[index]] = value.upcase!
      next
    end

    result[SESSION_COLUMNS[index]] = value
  end
  result
end

def mem_usage
  `ps -o rss= -p #{Process.pid}`.to_i / 1024
end

def add_user_stat(user, user_sessions, report)
  user = User.new(attributes: user, sessions: user_sessions)
  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"

  report['usersStats'][user_key] ||= {}
  report['usersStats'][user_key] = report['usersStats'][user_key]
                                     .merge('sessionsCount' => user.sessions.count)
                                     .merge('totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.')
                                     .merge('longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.')
                                     .merge('browsers' => user.sessions.map {|s| s['browser'] }.sort.join(', '))
                                     .merge('usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ })
                                     .merge('alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ })
                                     .merge('dates' => user.sessions.map{ |s| s['date'].chomp }.sort.reverse)
end

def work(file_name: 'data.txt')
  report = {}
  report[:totalUsers] = 0
  report['totalSessions'] = 0
  report['usersStats'] = {}
  all_browsers = []
  current_user = nil
  current_user_sessions = nil
  File.new(file_name).each_line do |line|
    case line[0]
    when 'u'
      add_user_stat(current_user, current_user_sessions, report) if current_user
      current_user = parse_user(line)
      report[:totalUsers] += 1
      current_user_sessions = []
    when 's'
      session = parse_session(line)
      current_user_sessions << session
      report['totalSessions'] += 1
      all_browsers << session['browser']
    end
  end
  add_user_stat(current_user, current_user_sessions, report)
  uniq_browsers = all_browsers.uniq
  report['uniqueBrowsersCount'] = uniq_browsers.count
  report['allBrowsers'] = uniq_browsers.uniq.sort.join(',')

  File.write('result.json', "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
