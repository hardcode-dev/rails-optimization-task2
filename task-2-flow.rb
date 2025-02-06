require_relative 'user'
require 'json'
require 'oj'

class SessionsProcessor
  LINE_SEPARATOR = ','.freeze
  USER_TYPE = 'user'.freeze
  SESSION_TYPE = 'session'.freeze

  attr_reader :total_users, :total_browsers, :total_sessions

  def initialize(filename)
    @filename = filename
    @total_users = 0
    @total_browsers = Set.new
    @total_sessions = 0
  end

  def process
    stream.push_object
    stream.push_key('usersStats')
    stream.push_object

    File.open(@filename).each do |line|
      process_line(line)
    end

    update_totals
    save_user if user

    stream.pop
    totals.each { |key, value| stream.push_value(value, key.to_s) }
    stream.pop_all
    io.close
  end

  private

  attr_reader :user

  def process_line(line)
    type, *info = line.strip.split(LINE_SEPARATOR)

    if type == USER_TYPE
      update_totals
      save_user if user
      @user = User.new(*info)
    end

    user.update_sessions_stats(*info) if type == SESSION_TYPE
  end

  def update_totals
    return unless user

    @total_users += 1
    @total_browsers.merge(user.browsers)
    @total_sessions += user.sessions_count
  end

  def totals
    {
      totalUsers: total_users,
      uniqueBrowsersCount: total_browsers.size,
      totalSessions: total_sessions,
      allBrowsers: total_browsers.to_a.sort.join(',')
    }
  end

  def stream
    @stream ||= Oj::StreamWriter.new(io)
  end

  def io
    @io ||= File.open('result.json', 'w')
  end

  def save_user
    stream.push_key("#{user.first_name} #{user.last_name}")
    stream.push_object
    user.as_json.each { |key, value| stream.push_value(value, key.to_s) }
    stream.pop
  end
end

def work(filename)
  stats = SessionsProcessor.new(filename)
  stats.process
end
