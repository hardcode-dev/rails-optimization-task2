# Deoptimized version of homework task

require 'json'
require 'pry'
require 'minitest/autorun'
require_relative 'json_writer'

class Parser
  attr_accessor :users_count, :sessions_count, :user, :user_sessions, :json_writer
  attr_reader :unique_browsers

  def initialize
    @users_count = 0
    @unique_browsers = []
    @sessions_count = 0
  end

  def work(file_name: "data.txt", disable_gc: false)
    GC.disable if disable_gc

    File.open('result.json', 'a') do |output_file|
      @json_writer = JsonWriter.new(output_file)
      @json_writer.prepare_user_stats

      File.readlines(file_name, chomp: true).each do |line|
        cols = line.split(',')
        parse_user(cols) if cols[0] == 'user'
        parse_session(cols) if cols[0] == 'session'
      end

      collect_stats_for_previous_user

      @json_writer.write_common_stats(@users_count, @unique_browsers, @sessions_count)

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

  def parse_user(fields)
    collect_stats_for_previous_user if @users_count > 0
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

  def collect_stats_for_previous_user
    collect_unique_browsers

    user_key = "#{@user['first_name']}" + ' ' + "#{@user['last_name']}"
    user_data = {
      'sessionsCount' => @user_sessions.count,
      'totalTime' => @user_sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',
      'longestSession' => @user_sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
      'browsers' => @user_sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
      'usedIE' => @user_sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
      'alwaysUsedChrome' => @user_sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
      'dates' => @user_sessions.map{|s| s['date']}.sort.reverse
    }

    @json_writer.write_user_stats(user_key, user_data)
  end
end
