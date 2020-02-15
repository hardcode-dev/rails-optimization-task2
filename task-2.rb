# optimized version of homework task
# frozen_string_literal: true

require 'set'

class Report
  attr_reader :report, :user, :user_name, :result_file

  IE = /INTERNET EXPLORER/.freeze
  CHROME = /CHROME/.freeze
  DATA_SPLITTER = ','.freeze
  SESSION_STRING = 'session'.freeze
  RESULT_FILE_NAME = 'result.json'.freeze

  def initialize
    @report = {
      totalUsers: 0,
      totalSessions: 0,
      allBrowsers: SortedSet.new
    }
    @user_name = nil
    @user = nil
    @result_file = File.new(RESULT_FILE_NAME, 'w')
  end

  def work(filename: 'data.txt')
    save_to_file("{\"usersStats\":{")

    IO.foreach(filename) do |line|
      cols = line.split(DATA_SPLITTER)

      next parse_session(cols[3].upcase!, cols[4].to_i, cols[5][0..-2]) if cols[0] == SESSION_STRING

      save_not_last_user_to_file unless user.nil?

      @user_name = "#{cols[2]} #{cols[3]}"
      refresh_user_instance
      report[:totalUsers] += 1
    end

    save_user_to_file
    save_result_to_file
    result_file.close
  end

  def refresh_user_instance
    @user = {
      sessionsCount: 0,
      totalTime: 0,
      longestSession: 0,
      browsers: [],
      usedIE: false,
      alwaysUsedChrome: true,
      dates: []
    }
  end

  def parse_session(browser, session_time, date)
    user[:sessionsCount] += 1
    user[:totalTime] += session_time
    user[:longestSession] = session_time if session_time > user[:longestSession]
    user[:browsers] << browser
    user[:usedIE] = true if !user[:usedIE] && browser.match?(IE)
    user[:alwaysUsedChrome] = false if user[:alwaysUsedChrome] && !(browser.match?(CHROME))
    user[:dates] << date

    report[:totalSessions] += 1
    report[:allBrowsers] << browser
  end

  def save_to_file(value)
    result_file.write value
  end

  def save_not_last_user_to_file
    save_user_to_file
    save_to_file(DATA_SPLITTER)
  end

  def save_user_to_file
    save_to_file(
      "\"#{user_name}\":{\"sessionsCount\":#{user[:sessionsCount]},\"totalTime\":\"#{user[:totalTime]} min.\",\"longestSession\":\"#{user[:longestSession]} min.\",\"browsers\":\"#{user[:browsers].sort!.join(', ')}\",\"usedIE\":#{user[:usedIE]},\"alwaysUsedChrome\":#{user[:alwaysUsedChrome]},\"dates\":#{user[:dates].sort!.reverse!}}"
    )
  end

  def save_result_to_file
    save_to_file(
      "},\"totalUsers\":#{report[:totalUsers]},\"uniqueBrowsersCount\":#{report[:allBrowsers].count},\"totalSessions\":#{report[:totalSessions]},\"allBrowsers\":\"#{report[:allBrowsers].to_a.join(',')}\"}"
    )
  end
end
