# frozen_string_literal: true

require 'set'
require 'oj'

class Parser
  SESSIONS_COUNT_KEY     = 'sessionsCount'
  TOTAL_TIME_KEY         = 'totalTime'
  LONGEST_SESSION_KEY    = 'longestSession'
  BROWSERS_KEY           = 'browsers'
  USED_IE_KEY            = 'usedIE'
  ALWAYS_USED_CHROME_KEY = 'alwaysUsedChrome'
  DATES_KEY              = 'dates'
  DELIMITER              = ','
  TEMP_FILE              = 'temp.txt'

  def work(file_path)
    total_users_count = 0
    unique_browsers = Set.new
    total_sessions_count = 0
    user_key = nil
    user_stats = {
      SESSIONS_COUNT_KEY => 0,
      TOTAL_TIME_KEY => 0,
      LONGEST_SESSION_KEY => 0,
      BROWSERS_KEY => [],
      USED_IE_KEY => false,
      ALWAYS_USED_CHROME_KEY => true,
      DATES_KEY => []
    }
    temp_file = File.open(TEMP_FILE, 'w')

    IO.foreach(file_path) do |line|
      cols = line.split(DELIMITER)

      if cols.size == 5 # User line contains 5 elements
        total_users_count += 1
        finalize_user_report(user_stats, user_key, temp_file, delimiter: true) if user_key
        user_key = build_user_key(cols)
      else
        total_sessions_count += 1
        date, time, browser = extract_session_data(cols)
        unique_browsers << browser
        update_user_stats(user_stats, date, time, browser)
      end
    end

    finalize_last_user_report(user_stats, user_key, temp_file)
    temp_file.close

    report_root = {
      'totalUsers' => total_users_count,
      'uniqueBrowsersCount' => unique_browsers.size,
      'totalSessions' => total_sessions_count,
      'allBrowsers' => unique_browsers.to_a.sort!.join(',').upcase,
      'usersStats' => {}
    }

    create_result_file(report_root)

    File.delete(TEMP_FILE)
  end

  private

  def build_user_key(cols)
    cols.pop
    second_name = cols.pop
    first_name = cols.pop

    "#{first_name} #{second_name}"
  end

  def extract_session_data(cols)
    date = cols.pop.chomp!
    time = cols.pop.to_i
    browser = cols.pop

    [date, time, browser]
  end

  def update_user_stats(user_stats, date, time, browser)
    user_stats[SESSIONS_COUNT_KEY] += 1
    user_stats[TOTAL_TIME_KEY] += time
    user_stats[LONGEST_SESSION_KEY] = time if time > user_stats[LONGEST_SESSION_KEY]
    user_stats[BROWSERS_KEY] << browser
    user_stats[USED_IE_KEY] = true if !user_stats[USED_IE_KEY] && browser.match?(/INTERNET EXPLORER/i)
    user_stats[ALWAYS_USED_CHROME_KEY] = false if user_stats[ALWAYS_USED_CHROME_KEY] && !browser.match?(/CHROME/i)
    user_stats[DATES_KEY] << date
  end

  def create_result_file(report_root)
    report_root_json = Oj.dump(report_root).delete_suffix('}}')

    File.open('result.json', 'w') do |file|
      file.write(report_root_json)

      IO.foreach(TEMP_FILE, ']}') do |user_stat|
        file.write(user_stat)
      end

      file.write("}}\n")
    end
  end

  def finalize_user_report(user_stats, user_key, temp_file, delimiter: false)
    complete_user_stats(user_stats)
    write_user_stats_to_temp_file(user_stats, user_key, temp_file, delimiter)
    clean_user_stats(user_stats)
  end
  alias_method :finalize_last_user_report, :finalize_user_report

  def complete_user_stats(user_stats)
    user_stats[TOTAL_TIME_KEY] = "#{user_stats[TOTAL_TIME_KEY]} min."
    user_stats[LONGEST_SESSION_KEY] = "#{user_stats[LONGEST_SESSION_KEY]} min."
    user_stats[BROWSERS_KEY] = user_stats[BROWSERS_KEY].sort!.join(', ').upcase
    user_stats[DATES_KEY] = user_stats[DATES_KEY].sort!.reverse!
  end

  def write_user_stats_to_temp_file(user_stats, user_key, temp_file, delimiter)
    json = Oj.dump(user_stats)
    str = "\"#{user_key}\":" + json
    str << DELIMITER if delimiter
    temp_file.write(str)
  end

  def clean_user_stats(user_stats)
    user_stats[SESSIONS_COUNT_KEY] = 0
    user_stats[TOTAL_TIME_KEY] = 0
    user_stats[LONGEST_SESSION_KEY] = 0
    user_stats[BROWSERS_KEY] = []
    user_stats[USED_IE_KEY] = false
    user_stats[ALWAYS_USED_CHROME_KEY] = true
    user_stats[DATES_KEY] = []
  end
end
