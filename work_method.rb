# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'minitest/autorun'
require 'oj'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

class Parser
  attr_accessor :users_count, :unique_browsers, :sessions_count, :user, :user_sessions, :json_writer

  def initialize
    @users_count = 0
    @unique_browsers = []
    @sessions_count = 0
  end

  def work(file_name: "data.txt")
    File.open('result.json', 'a') do |output_file|
      json_writer = Oj::StreamWriter.new(output_file)
      json_writer.push_object
      json_writer.push_key('usersStats')
      json_writer.push_object

      File.readlines(file_name, chomp: true).each do |line|
        cols = line.split(',')
        parse_user(cols, json_writer) if cols[0] == 'user'
        parse_session(cols) if cols[0] == 'session'
      end

      collect_stats_for_previous_user(json_writer)

      json_writer.pop

      json_writer.push_key('totalUsers')
      json_writer.push_value(@users_count)

      json_writer.push_key('uniqueBrowsersCount')
      json_writer.push_value(@unique_browsers.count)

      json_writer.push_key('totalSessions')
      json_writer.push_value(@sessions_count)

      json_writer.push_key('allBrowsers')
      json_writer.push_value(@unique_browsers.sort.join(','))

      json_writer.pop

      json_writer.flush

      puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    end
  end

  private

  def collect_unique_browsers
    @user_sessions.each do |session|
      browser = session['browser']
      @unique_browsers.push(browser) unless @unique_browsers.include?(browser)
    end
  end

  def parse_user(fields, json_writer)
    collect_stats_for_previous_user(json_writer) if @users_count > 0
    @users_count += 1

    @user_sessions = []
    @user = {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
    }
  end

  def parse_session(fields)
    @sessions_count += 1
    @user_sessions.push(
      {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3].upcase,
        'time' => fields[4],
        'date' => fields[5],
      }
    )
  end

  def collect_stats_for_previous_user(json_writer)
    collect_unique_browsers

    user_object = User.new(attributes: @user, sessions: @user_sessions)
    user_key = "#{user_object.attributes['first_name']}" + ' ' + "#{user_object.attributes['last_name']}"

    json_writer.push_key(user_key)
    json_writer.push_value(
      {
        'sessionsCount' => user_object.sessions.count,
        'totalTime' => user_object.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
        'longestSession' => user_object.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
        'browsers' => user_object.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
        'usedIE' => user_object.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
        'alwaysUsedChrome' => user_object.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
        'dates' => user_object.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }
      }
    )
  end
end
