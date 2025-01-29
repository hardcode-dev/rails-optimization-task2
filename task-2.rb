# frozen_string_literal: true

require_relative 'task-2'
require 'set'
require 'oj'
require 'pry'

class ParseFile
  def initialize(result_file_path: nil, data_file_path: nil)
    @result_file_path = result_file_path || 'data/result.json'
    @data_file_path = data_file_path || 'data/data_large.txt'
    @temp_file = File.open('temp.txt', 'w')
  end

  def parse_full_name(cols)
    cols.pop
    second_name = cols.pop
    first_name = cols.pop

    "#{first_name} #{second_name}"
  end

  def parse_session(cols)
    date = cols.pop.chomp
    time = cols.pop.to_i
    browser = cols.pop.upcase

    [date, time, browser]
  end

  def work
    unique_browsers = Set.new
    total_users = 0
    total_sessions = 0
    user_full_name = nil
    user_stats = init_user_stats

    File.foreach(data_file_path) do |line|
      cols = line.split(',')

      if line.start_with?('user')
        finish_recording_user_stats(user_stats, user_full_name) if user_full_name
        user_full_name = parse_full_name(cols)
        total_users += 1
      else
        date, time, browser = parse_session(cols)
        unique_browsers << browser
        update_user_stats(user_stats, date, time, browser)
        total_sessions += 1
      end
    end

    finish_recording_user_stats(user_stats, user_full_name, last_user: true)

    report = {
      totalUsers: total_users,
      uniqueBrowsersCount: unique_browsers.count,
      totalSessions: total_sessions,
      allBrowsers: unique_browsers.sort.join(','),
      usersStats: {}
    }

    write_report_file(report)
  end

  private

  attr_reader :result_file_path, :data_file_path, :temp_file

  def finish_recording_user_stats(user_stats, user_full_name, last_user: false)
    user_stats['longestSession'] = "#{user_stats['longestSession']} min."
    user_stats['totalTime'] = "#{user_stats['totalTime']} min."
    user_stats['browsers'] = user_stats['browsers'].sort.join(', ')
    user_stats['dates'] = user_stats['dates'].sort.reverse

    write_to_temp_file(user_stats, user_full_name, last_user)
    init_user_stats(user_stats)
  end

  def update_user_stats(user_stats, date, time, browser)
    user_stats['sessionsCount'] += 1
    user_stats['totalTime'] += time
    user_stats['longestSession'] = time > user_stats['longestSession'] ? time : user_stats['longestSession']
    user_stats['usedIE'] = browser.match?(/INTERNET EXPLORER/) unless user_stats['usedIE']
    user_stats['alwaysUsedChrome'] = user_stats['alwaysUsedChrome'] && browser.match?(/CHROME/)
    user_stats['browsers'] << browser
    user_stats['dates'] << date
  end

  def init_user_stats(stats = {})
    stats['sessionsCount'] = 0
    stats['totalTime'] = 0
    stats['longestSession'] = 0
    stats['browsers'] = []
    stats['usedIE'] = false
    stats['alwaysUsedChrome'] = true
    stats['dates'] = []

    stats
  end

  def write_to_temp_file(user_stats, user_full_name, last_user)
    json = Oj.dump(user_stats)
    if last_user
      temp_file.write("\"#{user_full_name}\":#{json}\n")
    else
      temp_file.write("\"#{user_full_name}\":#{json},\n")
    end
  end

  def write_report_file(report)
    temp_file.close

    file_start_string = Oj.dump(report, mode: :compat).delete_suffix('}}')
    File.open(result_file_path, 'w') do |file|
      file.write(file_start_string)

      File.foreach(temp_file.path) do |line|
        file.write(line.chomp!)
      end

      file.write("}}\n")
    end

    File.delete(temp_file.path)
  end
end
