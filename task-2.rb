# frozen_string_literal: true

# # Optimized version of homework task

require 'date'
require 'oj'

DEFAULT_PATH = ENV['DATA_FILE'] || 'data.txt'
VERBOSE = ENV['VERBOSE'] == 'true'

class SessionStats
  attr_reader :sessions

  def initialize(sessions)
    @sessions = sessions
  end

  def total_count
    sessions.count
  end

  def total_time
    sessions.reduce(0) { |summ, s| summ + s.time }
  end

  def longest_session
    sessions.map(&:time).max
  end

  def browsers
    sessions.map(&:browser).sort.join(', ')
  end

  def sessions_dates
    sessions.map(&:date).sort.reverse
  end

  def always_used_chrome?
    !sessions.detect { |s| s.browser !~ /CHROME/ }
  end

  def used_ie?
    !!sessions.detect { |s| s.browser =~ /INTERNET EXPLORER/ }
  end
end

class Session
  attr_reader :user_id, :session_id, :browser, :time, :date

  def initialize(attrs)
    @user_id = attrs[0]
    @session_id = attrs[1]
    @browser = attrs[2].upcase
    @time = attrs[3].to_i
    @date = attrs[4]
  end
end

class User
  attr_reader :id, :first_name, :last_name, :sessions

  def initialize(attrs)
    @id = attrs[0]
    @first_name = attrs[1]
    @last_name = attrs[2]
    @age = attrs[4]
    @sessions = []
  end

  def stats
    @stats ||= SessionStats.new(sessions)
  end

  def key
    "#{first_name} #{last_name}"
  end
end

class SessionStatsRenderer
  def self.call(user)
    {
      'sessionsCount' => user.stats.total_count,
      'totalTime' => "#{user.stats.total_time} min.",
      'longestSession' => "#{user.stats.longest_session} min.",
      'browsers' => user.stats.browsers,
      'usedIE' => user.stats.used_ie?,
      'alwaysUsedChrome' => user.stats.always_used_chrome?,
      'dates' => user.stats.sessions_dates
    }
  end
end

def work(path = DEFAULT_PATH, verbose: VERBOSE, disable_gc: false)
  GC.disable if disable_gc

  total_sessions = 0
  total_users = 0
  all_browsers = []

  File.open('result.json', 'a') do |output_file|
    json_writer = Oj::StreamWriter.new(output_file)
    json_writer.push_object
    json_writer.push_key('usersStats')
    json_writer.push_object

    File.foreach(path, 'user') do |chunk|
      current_user = nil
      chunk.split("\n") do |line|
        cols = line.split(',')
        case cols[0]
        when 'user'
          next
        when ''
          current_user = User.new(cols[1..-1])
        when 'session'
          current_user.sessions << Session.new(cols[1..-1])
        end
      end

      if current_user
        json_writer.push_key(current_user.key)
        json_writer.push_value(SessionStatsRenderer.call(current_user))
        total_sessions += current_user.sessions.count
        total_users += 1
        all_browsers |= current_user.sessions.map(&:browser)
      end
    end

    json_writer.pop

    json_writer.push_key('totalSessions')
    json_writer.push_value(total_sessions)

    json_writer.push_key('totalUsers')
    json_writer.push_value(total_users)

    json_writer.push_key('uniqueBrowsersCount')
    json_writer.push_value(all_browsers.size)

    json_writer.push_key('allBrowsers')
    json_writer.push_value(all_browsers.sort.join(','))

    json_writer.pop

    json_writer.flush
    output_file.rewind
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024) if verbose
end
