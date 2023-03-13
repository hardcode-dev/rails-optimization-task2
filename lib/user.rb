require 'json'
require 'pry'
require 'date'

# Пройтись по первым строкам, найти пользователя и его сессии
# Сохранить всё в переменные
# Посчитать статистику
# Пройтись по следующему пользователю

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

  output = File.open(output_path, 'w+')
  output.puts '{'
  output.puts '"usersStats": {'

  users = []
  sessions = []

  current_user = nil
  current_user_key = nil
  current_user_sessions = Array.new
  current_user_report = Hash.new

  File.open(input_path, 'r').each_line do |line|
    cols = line.split(LINE_DIVIDER)

    if cols[0] == USER
      unless current_user.nil? 
        current_user_report[:totalTime] = "#{current_user_report[:totalTime]} min."
        current_user_report[:longestSession] = "#{current_user_report[:longestSession]} min."
        current_user_report[:browsers] = current_user_report[:browsers].sort!.join(', ')
        current_user_report[:dates] = current_user_report[:dates].sort! { |a, b| b <=> a }.map! { |i| i.chomp }

        output.puts("\"#{current_user_key}\": #{current_user_report.to_json}#{LINE_DIVIDER}")
      end

      current_user_sessions = []

      current_user = {
        user_id: cols[1], 
        first_name: cols[2], 
        last_name: cols[3], 
        age: cols[4]
      }

      current_user_key = "#{current_user[:first_name]} #{current_user[:last_name]}"

      current_user_report = {
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
      current_user_report[:sessionsCount] += 1
      current_user_report[:totalTime] += session_time
      current_user_report[:longestSession] = session_time if session_time > current_user_report[:longestSession]
      current_user_report[:browsers] << browser
      current_user_report[:alwaysUsedChrome] = false if !browser.start_with?('CHROME')
      current_user_report[:usedIE] = true if browser.start_with?('INTERNET EXPLORER')
      current_user_report[:dates] << session[:date]

      report[:totalSessions] += 1
      unique_browsers << browser

      # if i + 1 == file_lines.count
      #   report[:usersStats][current_user_key][:totalTime] = "#{report[:usersStats][current_user_key][:totalTime]} min."
      #   report[:usersStats][current_user_key][:longestSession] = "#{report[:usersStats][current_user_key][:longestSession]} min."
      #   report[:usersStats][current_user_key][:browsers] = report[:usersStats][current_user_key][:browsers].sort!.join(', ')
      #   report[:usersStats][current_user_key][:dates] = report[:usersStats][current_user_key][:dates].sort! { |a, b| b <=> a }
      # end
    end
  end

  current_user_report[:totalTime] = "#{current_user_report[:totalTime]} min."
  current_user_report[:longestSession] = "#{current_user_report[:longestSession]} min."
  current_user_report[:browsers] = current_user_report[:browsers].sort!.join(', ')
  current_user_report[:dates] = current_user_report[:dates].sort! { |a, b| b <=> a }.map! { |i| i.chomp }

  output.puts("\"#{current_user_key}\": #{current_user_report.to_json}")

  output.puts '},'

  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.to_a.sort!.join(',')

  output.puts("\"totalUsers\":#{report[:totalUsers]}#{LINE_DIVIDER}")
  output.puts("\"uniqueBrowsersCount\":#{report[:uniqueBrowsersCount]}#{LINE_DIVIDER}")
  output.puts("\"totalSessions\":#{report[:totalSessions]}#{LINE_DIVIDER}")
  output.puts("\"allBrowsers\":\"#{report[:allBrowsers]}\"")

  output.puts '}'
  output.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end