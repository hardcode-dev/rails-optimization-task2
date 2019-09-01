# frozen_string_literal: true
require 'json'
require 'pry'
require 'set'
require 'oj'
require './user.rb'

class Report
  attr_reader :file, :summary

  def initialize(file)
    @file = file
    @summary = { 'totalUsers' => 0, 'uniqueBrowsersCount' => 0, 'totalSessions' => 0, 'allBrowsers' => '', 'usersStats' => {} }
  end

  def work
    File.write('users_stats.json', '')
    parse_file
    generate_result
    GC.start(full_mark: true, immediate_sweep: true)
  end

  private

  def generate_result
    result = 'result.json'
    stats = 'users_stats.json'
    counter = 0

    File.write(result, Oj.dump(@summary)[0..-3])

    counter = 0
    total_users = @summary['totalUsers']

    IO.foreach(stats) do |line|
      counter += 1
      File.open(result, 'a') do |f|
        f << "#{Oj.dump(Oj.load(line))[1..-2]}#{counter < total_users ? ',' : ''}"
      end
    end

    File.open(result, 'a') { |f| f << "}}\n" }
  end

  def parse_file
    user = nil
    unique_browsers = Set.new
    total_sessions = 0
    total_users = 0

    IO.foreach(file) do |line|
      cols = line.split(",")

      if cols[0] == 'user'
        collect_stats_from_user(user)

        user = User.new(attributes: parse_user(cols), sessions: [])
        total_users += 1
      else
        session = parse_session(cols)
        user.sessions << session

        unique_browsers << session['browser']
        total_sessions += 1
      end
    end

    collect_stats_from_user(user)

    @summary['totalUsers'] = total_users
    @summary['uniqueBrowsersCount'] = unique_browsers.count
    @summary['totalSessions'] = total_sessions
    @summary['allBrowsers'] = unique_browsers.map { |b| b.upcase }.sort.join(',')
  end


  def collect_stats_from_user(user)
    generate_users_stats_json(user.key => user_data(user)) if user
  end


  def generate_users_stats_json(user)
    File.open('users_stats.json', 'a') { |f| f.puts "#{Oj.dump(user)}\n" }
  end

  def user_data(user)
    sessions_time = user.sessions.map {|s| s['time'].to_i }
    browsers = user.sessions.map{ |s| s['browser'].upcase }
    browsers_string = browsers.sort.join(', ')

    {
      'sessionsCount'    => user.sessions.count,
      'totalTime'        => "#{sessions_time.sum.to_s} min.",
      'longestSession'   => "#{sessions_time.max.to_s} min.",
      'browsers'         => browsers_string,
      'usedIE'           => browsers_string.match?('INTERNET'),
      'alwaysUsedChrome' => !browsers.any? { |b| !b.include?('CHROME') },
      'dates'            => user.sessions.map{|s| s['date'] }.sort!.reverse!
    }
  end

  def parse_user(user)
    {
      'id' => user[1],
      'first_name' => user[2],
      'last_name' => user[3],
      'age' => user[4].strip
    }
  end

  def parse_session(session)
    {
      'user_id' => session[1],
      'session_id' => session[2],
      'browser' => session[3],
      'time' => session[4],
      'date' => session[5].strip
    }
  end
end
