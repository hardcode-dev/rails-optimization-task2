# frozen_string_literal: true

require 'json'
require './helpers/row/user'
require './helpers/row/session'
require './models/user'

class App
  SPLIT_CHAR   = ','
  USER_TYPE    = 'user'
  SESSION_TYPE = 'session'

  def initialize(file_name)
    @file_name = file_name
    @browsers  = []

    @report = {
      total_users:           0,
      unique_browsers_count: 0,
      total_sessions:        0,
      all_browsers:          ''
    }

    @report_file = File.new('result.json', 'w')
  end

  def work
    report_file.write('{"usersStats":{')

    current_user     = nil
    current_sessions = []

    File.open(file_name) do |file|
      print_memory 'MEMORY USAGE AFTER OPEN FILE'

      file.each_line do |line|
        row = line.split(SPLIT_CHAR)

        if row[0] == USER_TYPE
          user_stats(current_user, current_sessions) if current_user && current_sessions.any?

          current_user     = row
          current_sessions = []
        end

        current_sessions << session_stats(row) if row[0] == SESSION_TYPE
        user_stats(current_user, current_sessions, last: true) if file.eof?
      end
    end

    save_report
    print_memory 'MEMORY USAGE AFTER COMPLETE APP'
  end

  private

  attr_accessor :file_name, :browsers, :report, :report_file

  def user_stats(attributes, sessions, last: false)
    user  = User.new(attributes, sessions)
    stats = "\"#{user.full_name}\":#{user.stats.to_json}"
    stats += ',' unless last
    stats

    report_file.write(stats)
    # IO.write('result.json', stats, mode: 'a')

    report[:total_users] += 1
  end

  def session_stats(row)
    unless browsers.include?(row[Row::Session::BROWSER])
      browsers << row[Row::Session::BROWSER]

      report.merge!(
        unique_browsers_count: browsers.count,
        all_browsers:          browsers.sort.join(SPLIT_CHAR).upcase
      )
    end

    report[:total_sessions] += 1

    row
  end

  def save_report
    summary = <<-JSON
    },
    "totalUsers":#{report[:total_users]},
    "uniqueBrowsersCount":#{report[:unique_browsers_count]},
    "totalSessions":#{report[:total_sessions]},
    "allBrowsers":"#{report[:all_browsers]}"
    }
    JSON

    report_file.write(summary)
    report_file.close
  end

  def print_memory(msg = 'MEMORY USAGE')
    puts format("#{msg}: %d MB", (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
  end
end

# App.new('data.txt').work
