# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'
require 'oj'
require "./measure.rb"
require 'tempfile'

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def collect_data(file, hash_key, user)
  user[:totalTime] = "#{user[:totalTime]} min."
  user[:longestSession] = "#{user[:longestSession]} min."
  user[:dates] = user[:dates].sort!.reverse!
  user[:browsers] = user[:browsers].sort!.join(', ')
  file.write "#{hash_key}: #{Oj.dump(user, mode: :compat)}"
end

def work(filename = '', disable_gc: true)
  puts "1: #{print_memory_usage}"
  GC.disable if disable_gc

  users = []
  sessions = {}
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: nil,
  }

  user = nil
  hash_key = nil
  File.open('temp', 'w') do |temp|
    File.open(filename).each do |line|
      cols = line.split(',')
      if cols[0] == 'user'
        report[:totalUsers] += 1
        if user
          collect_data(temp, hash_key, user)
          temp.write ", \n"
        end
        hash_key = "\"#{cols[2]} #{cols[3]}\"".to_sym
        user = {
          sessionsCount: 0,
          totalTime: 0,
          longestSession: 0,
          browsers: [],
          usedIE: false,
          alwaysUsedChrome: true,
          dates: [],
        }
      else
        cols[3].upcase!
        cols[4] = cols[4].to_i
        user[:sessionsCount] += 1
        user[:totalTime] += cols[4]
        user[:longestSession] = cols[4] if user[:longestSession] < cols[4]
        user[:browsers].push(cols[3])
        user[:usedIE] = true if !user[:usedIE] && cols[3].start_with?('INTERNET')
        user[:alwaysUsedChrome] = false if user[:alwaysUsedChrome] && !cols[3].start_with?('CHROME')
        user[:dates].push(cols[5].chomp)
        report[:totalSessions] += 1
        sessions[cols[3]] = nil
      end
    end
    collect_data(temp, hash_key, user)
  end

  report[:uniqueBrowsersCount] = sessions.keys.count
  report[:allBrowsers] = sessions.keys.sort!.join(',')


  File.open('result.json', 'w') do |f|
    report_json = Oj.dump(report, mode: :compat)
    f.write report_json.delete_suffix('}')
    f.write ', "usersStats": {'
    File.open('temp').each do |line|
      f.write line.chomp
    end
    f.write "}}"
    f.write "\n"
  end
  puts "2: #{print_memory_usage}"
end
