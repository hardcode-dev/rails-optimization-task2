# frozen_string_literal: true

require "json"
require "date"
require "oj"

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

class Report
  attr_reader :file_path

  attr_accessor :curret_user_id

  def initialize(file_path)
    @file_path = file_path
    # Result file.
    @result_file = File.open("result.json", "w")
    # Current user id.
    @curret_user_id = nil
    # Current user statistic.
    @current_user = {}
    # Is user first?
    @is_first_user = true
    # Total users count.
    @total_users_count = 0
    # Total sessions count.
    @total_sessions_count = 0
    # Unique browsers.
    @unique_browsers = SortedSet[]
  end

  def work
    GC.enable

    write_users_stats

    File.open(@file_path, "r").each do |line|
      cols = line.split(",")

      parse_user(cols) if cols[0] == "user"
      parse_session(cols) if cols[0] == "session"
    end

    finalize_report
  end

  def write(text)
    @result_file.write(text)
  end

  def write_users_stats
    write("{\"usersStats\":{")
  end

  def parse_user(fields)
    finalize_user unless @curret_user_id.nil?

    @total_users_count += 1
    @curret_user_id = fields[1]

    user_key = "#{fields[2]} #{fields[3]}"

    @current_user[user_key] = {
      "sessionsCount" => 0,
      "totalTime" => 0,
      "longestSession" => 0,
      "browsers" => [],
      "usedIE" => false,
      "alwaysUsedChrome" => true,
      "dates" => SortedSet[],
    }
  end

  def finalize_user
    @current_user.each do |user_key, stats|
      stats["totalTime"] = "#{stats["totalTime"]} min."
      stats["longestSession"] = "#{stats["longestSession"]} min."
      stats["browsers"] = stats["browsers"].sort.join(", ")
      stats["dates"] = stats["dates"].to_a.reverse

      if @is_first_user
        write("\"#{user_key}\":")

        @is_first_user = false
      else
        write(",\"#{user_key}\":")
      end

      write(Oj.dump(stats))
    end

    @current_user = {}
  end

  def parse_session(fields)
    @total_sessions_count += 1

    current_user_stats = @current_user.values.last

    browser = fields[3].upcase
    time = fields[4].to_i
    date = fields[5].chomp

    current_user_stats["sessionsCount"] += 1
    current_user_stats["totalTime"] += time
    current_user_stats["longestSession"] = time if time > current_user_stats["longestSession"]
    current_user_stats["dates"].add(date)
    current_user_stats["usedIE"] ||= browser.match?(/INTERNET EXPLORER/i)
    current_user_stats["browsers"] << browser
    current_user_stats["alwaysUsedChrome"] &&= browser.match?(/CHROME/i)

    @unique_browsers.add(browser)
  end

  def finalize_report
    finalize_user

    write("},\"totalUsers\":#{@total_users_count},")
    write("\"totalSessions\":#{@total_sessions_count},")
    write("\"uniqueBrowsersCount\":#{@unique_browsers.count},")
    write("\"allBrowsers\":\"#{@unique_browsers.to_a.join(",")}\"}")

    @result_file.close
  end
end
