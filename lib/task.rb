# frozen_string_literal: true

class Task
  COMMA = ','.freeze
  COMMA_WITH_INDENT = ', '.freeze
  USER = 'user'.freeze
  TOTAL_TIME = 'totalTime'
  SESSIONS_COUNT = 'sessionsCount'
  USED_IE = 'usedIE'
  ALWAYS_USED_CHROME = 'alwaysUsedChrome'
  BROWSERS = 'browsers'
  DATES = 'dates'
  LONGEST_SESSION = 'longestSession'
  TIME = 'time'
  DATE = 'date'
  BROWSER = 'browser'

  def initialize(result_file_path: nil, data_file_path: nil)
    @result_file_path = result_file_path || 'data/result.json'
    @data_file_path = data_file_path || 'data/data_large.txt'
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
    browser = cols.pop

    [date, time, browser]
  end

  def work
    uniqueBrowsers = Set.new
    report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: 0, usersStats: {} }
    user_full_name = nil

    user_stats = init_user_stats

    File.foreach(data_file_path) do |line|
      cols = line.split(COMMA)

      if line.start_with?(USER)
        finalize_user_stats(user_stats, report, user_full_name) unless  user_full_name.nil?
        user_full_name = parse_full_name(cols)
        report[:totalUsers] += 1
      else
        date, time, browser = parse_session(cols)
        uniqueBrowsers << browser
        update_user_stats(user_stats, date, time, browser)
        report[:totalSessions] += 1
      end
    end

    finalize_user_stats(user_stats, report, user_full_name)

    report[:uniqueBrowsersCount] = uniqueBrowsers.count
    report[:allBrowsers] = uniqueBrowsers.sort.join(COMMA)

    File.write(result_file_path, "#{Oj.dump(report, mode: :compat)}\n")
  end

  private

  attr_reader :result_file_path, :data_file_path

  def finalize_user_stats(user_stats, report, user_full_name)
    user_stats[LONGEST_SESSION] = "#{user_stats[LONGEST_SESSION]} min."
    user_stats[TOTAL_TIME] = "#{user_stats[TOTAL_TIME]} min."
    user_stats[BROWSERS] = user_stats[BROWSERS].sort.join(COMMA_WITH_INDENT)
    user_stats[DATES] = user_stats[DATES].sort { |a, b| b <=> a }

    report[:usersStats][user_full_name] = user_stats.clone
    init_user_stats(user_stats)
  end

  def update_user_stats(user_stats, date, time, browser)
    user_stats[SESSIONS_COUNT] += 1
    user_stats[TOTAL_TIME] += time
    user_stats[LONGEST_SESSION] = time > user_stats[LONGEST_SESSION] ? time : user_stats[LONGEST_SESSION]
    user_stats[USED_IE] = browser.match?(/INTERNET EXPLORER/) unless user_stats[USED_IE]
    user_stats[ALWAYS_USED_CHROME] = user_stats[ALWAYS_USED_CHROME] && browser.match?(/CHROME/)
    user_stats[BROWSERS] << browser
    user_stats[DATES] << date
  end

  def init_user_stats(stats = {})
    stats[SESSIONS_COUNT] = 0
    stats[TOTAL_TIME] = 0
    stats[LONGEST_SESSION] = 0
    stats[BROWSERS] = []
    stats[USED_IE] = false
    stats[ALWAYS_USED_CHROME] = true
    stats[DATES] = []

    stats
  end
end
