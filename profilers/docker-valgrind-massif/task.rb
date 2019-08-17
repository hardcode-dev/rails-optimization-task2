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
    uniqueBrowsers = Set.new
    totalUsers = 0
    totalSessions = 0
    user_full_name = nil
    user_stats = init_user_stats

    File.foreach(data_file_path) do |line|
      cols = line.split(COMMA)

      if line.start_with?(USER)
        finalize_user_stats(user_stats, user_full_name) if user_full_name
        user_full_name = parse_full_name(cols)
        totalUsers += 1
      else
        date, time, browser = parse_session(cols)
        uniqueBrowsers << browser
        update_user_stats(user_stats, date, time, browser)
        totalSessions += 1
      end
    end

    finalize_user_stats(user_stats, user_full_name, delimetr: false)

    report = {
      totalUsers: totalUsers,
      uniqueBrowsersCount: uniqueBrowsers.count,
      totalSessions: totalSessions,
      allBrowsers: uniqueBrowsers.sort.join(COMMA),
      usersStats: {}
    }

    write_report_file(report)
  end

  private

  attr_reader :result_file_path, :data_file_path, :temp_file

  def finalize_user_stats(user_stats, user_full_name, delimetr: true)
    user_stats[LONGEST_SESSION] = "#{user_stats[LONGEST_SESSION]} min."
    user_stats[TOTAL_TIME] = "#{user_stats[TOTAL_TIME]} min."
    user_stats[BROWSERS] = user_stats[BROWSERS].sort.join(COMMA_WITH_INDENT)
    user_stats[DATES] = user_stats[DATES].sort { |a, b| b <=> a }

    write_to_temp_file(user_stats, user_full_name, delimetr)
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

  def write_to_temp_file(user_stats, user_full_name, delimetr)
    json = Oj.dump(user_stats)
    if delimetr
      temp_file.write("\"#{user_full_name}\":#{json},\n")
    else
      temp_file.write("\"#{user_full_name}\":#{json}\n")
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
