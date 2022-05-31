# frozen_string_literal: true

require 'json'
require 'oj'
require 'minitest/autorun'
require 'set'

def parse_session(session)
  {
    'browser' => session[0],
    'time' => session[1],
    'date' => session[2],
  }
end

def collect_stats_from_users(user, sessions)
  total_time = 0
  longest_session = 0
  browsers = []
  dates_strings = SortedSet[]
  user['ie_user'] = false
  sessions.map do |session|
    time = session['time'].to_i
    total_time += time
    longest_session = time if time > longest_session
    browser = session['browser'].upcase
    browsers << browser
    if browser.start_with? 'INTERNET EXPLORER'
      user['ie_user'] = true
    end
    dates_strings << session['date']
  end

  always_use_chrome = user['ie_user'] ? false : browsers.all? { |b| b.start_with? 'CHROME' }

  {
    'sessionsCount' => sessions.count,
    'totalTime' => "#{total_time} min.",
    'longestSession' => "#{longest_session} min.",
    'browsers' => browsers.sort.join(', '),
    'usedIE' => user['ie_user'],
    'alwaysUsedChrome' => always_use_chrome,
    'dates' => dates_strings.to_a.reverse
  }
end

def work(file_name: 'data.txt', gc_disabled: false)
  GC.disable if gc_disabled

  filename = File.join(File.dirname(__FILE__), 'result.json')
  File.open(filename, "w") do |f|
    @streamer = Oj::StreamWriter.new(f, :indent => 0)
    @streamer.push_object
    @streamer.push_object("usersStats")

    @sessions_count = 0
    @users_count = 0
    all_browsers = []

    @user_sessions = []
    File.foreach(file_name) do |line|
      if line.start_with? 'u'
        unless @user_sessions.empty?
          user_stats = collect_stats_from_users(@parsed_user, @user_sessions)
          @user_key = @parsed_user['first_name'] + ' ' + @parsed_user['last_name']
          @streamer.push_json(user_stats.to_json, @user_key)
          @user_sessions = []
        end

        line.strip!
        user_attrs = []
        line.split(',') do |col|
          user_attrs << col if col.match /[[:upper:]]/
        end
        @parsed_user = {
          'first_name' => user_attrs[0],
          'last_name' => user_attrs[1]
        }

        @users_count += 1
      elsif line.start_with? 's'
        line.strip!
        line.gsub!(/\w*,\d,\d,/, '')
        cols = line.split(',')
        parsed_session = parse_session(cols)
        all_browsers << parsed_session['browser'].upcase!
        @user_sessions << parsed_session
        @sessions_count += 1
      end
    end

    unless @user_sessions.empty?
      user_stats = collect_stats_from_users(@parsed_user, @user_sessions)
      @user_key = "#{@parsed_user['first_name']} #{@parsed_user['last_name']}"
      @streamer.push_json(user_stats.to_json, @user_key)
      @user_sessions = []
    end
    uniq_browsers = all_browsers.uniq

    @streamer.pop
    @streamer.push_json(@users_count.to_s, 'totalUsers')
    @streamer.push_json(uniq_browsers.count.to_s, 'uniqueBrowsersCount')
    @streamer.push_json(@sessions_count.to_s, 'totalSessions')
    @streamer.push_json(uniq_browsers.sort.join(',').to_json, 'allBrowsers')
    @streamer.pop_all

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end
end
