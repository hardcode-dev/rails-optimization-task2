require 'json'
require 'pry'
require 'date'

LINE_DIVIDER = ','.freeze
USER = 'user'.freeze
SESSION = 'session'.freeze

def work(input_path:, output_path:)
  report = {}

  report[:totalUsers] = 0

  unique_browsers = Set.new
  report[:uniqueBrowsersCount] = 0
  report[:totalSessions] = 0
  report[:allBrowsers] = []

  report[:usersStats] = {}

  file_lines = File.read(input_path).split("\n")

  users = []
  sessions = []

  current_user = nil
  current_user_key = nil

  file_lines.each_with_index do |line, i|
    cols = line.split(LINE_DIVIDER)

    if cols[0] == USER
      if !current_user.nil? 
        report[:usersStats][current_user_key][:totalTime] = "#{report[:usersStats][current_user_key][:totalTime]} min."
        report[:usersStats][current_user_key][:longestSession] = "#{report[:usersStats][current_user_key][:longestSession]} min."
        report[:usersStats][current_user_key][:browsers] = report[:usersStats][current_user_key][:browsers].sort!.join(', ')
        report[:usersStats][current_user_key][:dates] = report[:usersStats][current_user_key][:dates].sort! { |a, b| b <=> a }
      end

      current_user = {
        user_id: cols[1], 
        first_name: cols[2], 
        last_name: cols[3], 
        age: cols[4]
      }

      current_user_key = "#{current_user[:first_name]} #{current_user[:last_name]}"

      report[:usersStats][current_user_key] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: true,
        dates: []
      }

      report[:totalUsers] += 1
    end
    if cols[0] == SESSION
      session = {
        user_id: cols[1],
        session_id: cols[2],
        browser: cols[3],
        time: cols[4],
        date: cols[5],
      }

      browser = session[:browser].upcase
      session_time = session[:time].to_i
      report[:usersStats][current_user_key][:sessionsCount] += 1
      report[:usersStats][current_user_key][:totalTime] += session_time
      report[:usersStats][current_user_key][:longestSession] = session_time if session_time > report[:usersStats][current_user_key][:longestSession]
      report[:usersStats][current_user_key][:browsers] << browser
      report[:usersStats][current_user_key][:alwaysUsedChrome] = false if !browser.start_with?('CHROME')
      report[:usersStats][current_user_key][:usedIE] = true if browser.start_with?('INTERNET EXPLORER')
      report[:usersStats][current_user_key][:dates] << session[:date]

      report[:totalSessions] += 1
      unique_browsers << browser

      if i + 1 == file_lines.count
        report[:usersStats][current_user_key][:totalTime] = "#{report[:usersStats][current_user_key][:totalTime]} min."
        report[:usersStats][current_user_key][:longestSession] = "#{report[:usersStats][current_user_key][:longestSession]} min."
        report[:usersStats][current_user_key][:browsers] = report[:usersStats][current_user_key][:browsers].sort!.join(', ')
        report[:usersStats][current_user_key][:dates] = report[:usersStats][current_user_key][:dates].sort! { |a, b| b <=> a }
      end
    end
  end

  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.to_a.sort!.join(',')

  File.write(output_path, "#{report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end