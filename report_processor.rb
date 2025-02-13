# frozen_string_literal: true

require 'oj'
require 'pry'

class ReportProcessor
  def initialize
    @users_count = 0
    @sessions_count = 0
    @uniq_browsers = Set.new
    @current_user = nil
  end

  attr_accessor :uniq_browsers, :sessions_count, :users_count, :current_user

  User = Struct.new(:id, :first_name, :last_name, :age, :sessions, :session_stats, keyword_init: true)

  def call(input_file_name:, disable_gc: false)
    GC.disable if disable_gc

    with_stream_writer('result.json') do |stream_writer|
      build_json_report(input_file_name, stream_writer)
    end

    puts "MEMORY USAGE: #{(`ps -o rss= -p #{Process.pid}`.to_i / 1024)} MB"
  end

  private

  def with_stream_writer(result_file)
    File.open(result_file, 'w') do |file|
      stream_writer = Oj::StreamWriter.new(file)

      yield(stream_writer)
    end
  end

  def build_json_report(file_name, stream_writer)
    stream_writer.push_object
    stream_writer.push_key('usersStats')
    stream_writer.push_object

    process_file(file_name, stream_writer)

    stream_writer.pop
    stream_writer.push_value(users_count, 'totalUsers')
    stream_writer.push_value(uniq_browsers.size, 'uniqueBrowsersCount')
    stream_writer.push_value(sessions_count, 'totalSessions')
    stream_writer.push_value(uniq_browsers.sort.join(','), 'allBrowsers')

    stream_writer.pop_all
  end

  def process_file(file_name, stream_writer)
    File.foreach(file_name) do |line|
      fields = line.chomp!.split(',')

      case fields[0]
      when 'user'
        flush_current_user(stream_writer) if current_user
        @users_count += 1
        @current_user = User.new(id: fields[1], first_name: fields[2], last_name: fields[3], sessions: [], session_stats: {})
      when 'session'
        @sessions_count += 1
        session = { user_id: fields[1], session_id: fields[2], browser: fields[3], time: fields[4], date: fields[5] }
        current_user.sessions << session
        uniq_browsers << session[:browser].upcase
      end
    end

    flush_current_user(stream_writer) if current_user
  end

  def flush_current_user(stream_writer)
    current_user.session_stats = collect_stats_for(current_user)

    write_user_to_stream(current_user, stream_writer)
    @current_user = nil
  end

  def collect_stats_for(user)
    return {} if user.sessions.empty?

    stats =
      user.sessions.each_with_object({ total_time: 0, longest_session: 0, browser: [], dates: [], used_ie: false, always_chrome: false }) do |session, hash|
        time = session[:time].to_i
        hash[:total_time] += time
        hash[:longest_session] = time if time > hash[:longest_session]
        hash[:browser] << session[:browser].upcase
        hash[:dates] << session[:date]
        hash[:used_ie] ||= (session[:browser].upcase =~ /INTERNET EXPLORER/)
        hash[:always_chrome] &&= (session[:browser].upcase =~ /CHROME/)
      end

    {
      sessionsCount: user.sessions.size,
      totalTime: "#{stats[:total_time]} min.",
      longestSession: "#{stats[:longest_session]} min.",
      browsers: stats[:browser].sort.join(', '),
      usedIE: !!stats[:used_ie],
      alwaysUsedChrome: !!stats[:always_chrome],
      dates: stats[:dates].sort.reverse
    }
  end

  def write_user_to_stream(user, stream_writer)
    return unless user

    user_key = "#{user.first_name} #{user.last_name}"
    stream_writer.push_key(user_key)
    stream_writer.push_object
    user.session_stats.each { |key, value| stream_writer.push_value(value, key.to_s) }

    stream_writer.pop
  end
end
