# optimized version of homework task

require 'set'
require 'oj'

class Report
  attr_reader :result_file

  IE = /INTERNET EXPLORER/.freeze
  CHROME = /CHROME/.freeze
  DATA_SPLITTER = ','.freeze
  SESSION_STRING = 'session'.freeze
  JOINER = ', '.freeze
  MIN = ' min.'.freeze

  def initialize
    @report_total_users = 0
    @report_total_sessions = 0
    @report_all_browsers = SortedSet.new
    @result_file = File.open('result.json', 'a')
  end

  def work(filename: 'data.txt')
    save_to_file("{\"usersStats\":{")

    IO.foreach(filename) do |line|
      cols = line.split(DATA_SPLITTER)[2..5]

      next parse_session(cols[1].upcase!, cols[2].to_i, cols[3].chomp!) unless cols[3].nil?

      save_not_last_user_to_file unless @userSessionsCount.nil?

      save_to_file("\"#{cols[0]} #{cols[1]}\":")
      refresh_user_instance
      @report_total_users += 1
    end

    save_user_to_file
    save_result_to_file
    result_file.close
  end

  def refresh_user_instance
    @userSessionsCount = 0
    @userTotalTime = 0
    @userLongestSession = 0
    @userBrowsers = []
    @userUsedIE = false
    @userAlwaysUsedChrome = true
    @userDates = []
  end

  def parse_session(browser, session_time, date)
    @userSessionsCount += 1
    @userTotalTime += session_time
    @userLongestSession = session_time if session_time > @userLongestSession
    @userBrowsers << browser
    @userUsedIE = true if !@userUsedIE && browser.match?(IE)
    @userAlwaysUsedChrome = false if @userAlwaysUsedChrome && !(browser.match?(CHROME))
    @userDates << date

    @report_total_sessions += 1
    @report_all_browsers << browser
  end

  def save_to_file(value)
    result_file.write value
  end

  def save_not_last_user_to_file
    save_user_to_file
    save_to_file(DATA_SPLITTER)
  end

  def save_user_to_file
    user_stats = {}
    user_stats["sessionsCount"] = @userSessionsCount
    user_stats['totalTime'] = @userTotalTime.to_s << MIN
    user_stats['longestSession'] = @userLongestSession.to_s << MIN
    user_stats['browsers'] = @userBrowsers.sort!.join(JOINER)
    user_stats["usedIE"] = @userUsedIE
    user_stats["alwaysUsedChrome"] = @userAlwaysUsedChrome
    user_stats['dates'] = @userDates.sort!.reverse!

    save_to_file Oj.dump(user_stats)
  end

  def save_result_to_file
    save_to_file(
      "},\"totalUsers\":#{@report_total_users},\"uniqueBrowsersCount\":#{@report_all_browsers.count},\"totalSessions\":#{@report_total_sessions},\"allBrowsers\":\"#{@report_all_browsers.to_a.join(DATA_SPLITTER)}\"}"
    )
  end
end
