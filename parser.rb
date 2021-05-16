# frozen_string_literal: true

require 'json'
# require 'pry'
require 'date'
# require 'byebug'

class Parser
  def initialize(disable_gc: false)
    GC.disable if disable_gc

    @report_file = File.open('data/result.json', 'w')
    @user_stats = {}
    @all_stats = set_all_stats_struct
  end

  def work(file)
    @report_file << '{"usersStats":{'

    File.open(file, 'r').each do |line|
      line.start_with?('user') ? processing_user(line) : processing_session(line)
    end

    finish_calculation

    @report_file.close

    # puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  def processing_user(line)
    add_user_stats

    @user_stats = set_user_stats_struct

    line = line.split(',')
    user = parse_user(line)
    @user_stats['user_name'] = "#{user['first_name']} #{user['last_name']}"

    @all_stats['totalUsers'] += 1
  end

  def add_user_stats(last: false)
    return unless @user_stats['user_name']

    @report_file << "\"#{@user_stats['user_name']}\":{\"sessionsCount\":#{@user_stats['sessionsCount']},"
    @report_file << "\"totalTime\":\"#{@user_stats['totalTime']} min.\","
    @report_file << "\"longestSession\":\"#{@user_stats['longestSession']} min.\","
    @report_file << "\"browsers\":\"#{@user_stats['browsers'].sort.join(', ')}\","
    @report_file << "\"usedIE\":#{@user_stats['usedIE']},"
    @report_file << "\"alwaysUsedChrome\":#{@user_stats['alwaysUsedChrome']},"
    @report_file << "\"dates\":#{@user_stats['dates'].sort!.reverse!}}"
    @report_file << (last ? '},' : ',')
  end

  def processing_session(fields)
    fields = fields[/([^,]+),(\d+),([\d-]+)$/]
    fields = fields.split(',')
    session = parse_session(fields)

    # Stats
    @all_stats['totalSessions'] += 1
    @all_stats['allBrowsers'] << session['browser'] unless @all_stats['allBrowsers'].include?(session['browser'])
    # User stats
    @user_stats['sessionsCount'] += 1
    @user_stats['totalTime'] += session['time']
    @user_stats['longestSession'] = session['time'] if session['time'] > @user_stats['longestSession']
    @user_stats['browsers'] << session['browser']
    @user_stats['usedIE'] = true if /INTERNET EXPLORER/.match?(session['browser'])
    @user_stats['alwaysUsedChrome'] = false unless /CHROME/.match?(session['browser'])
    @user_stats['dates'] << session['date']
  end

  def finish_calculation
    add_user_stats(last: true)

    @report_file << "\"totalUsers\":#{@all_stats['totalUsers']},"
    @report_file << "\"uniqueBrowsersCount\":#{@all_stats['allBrowsers'].count},"
    @report_file << "\"totalSessions\":#{@all_stats['totalSessions']},"
    @report_file << "\"allBrowsers\":\"#{@all_stats['allBrowsers'].sort!.join(',')}\"}"
  end

  def set_all_stats_struct
    {
      'totalUsers' => 0,
      'uniqueBrowsersCount' => 0,
      'totalSessions' => 0,
      'allBrowsers' => []
    }
  end

  def set_user_stats_struct
    {
      'user_name' => nil,
      'sessionsCount' => 0,
      'totalTime' => 0,
      'longestSession' => 0,
      'browsers' => [],
      'usedIE' => false,
      'alwaysUsedChrome' => false,
      'dates' => []
    }
  end

  def parse_user(user)
    {
      'first_name' => user[2],
      'last_name' => user[3]
    }
  end

  def parse_session(session)
    {
      'browser' => session[0].upcase,
      'time' => session[1].to_i,
      'date' => session[2]
    }
  end
end

Parser.new.work('data/data_large.txt')

