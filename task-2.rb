# frozen_string_literal: true

require 'oj'

IE = 'INTERNET EXPLORER'.freeze

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def write_temp_user(f, user_name, user, trim_line = false)
  user[:totalTime] = user[:totalTime].to_s.concat(' min.')
  user[:longestSession] = user[:longestSession].to_s.concat(' min.')
  user[:dates].sort!.reverse!
  user[:usedIE] = user[:browsers].any? { |b| b.include?(IE) }
  user[:alwaysUsedChrome] = user[:browsers].all? { |b| b =~ /CHROME/ }
  user[:browsers] = user[:browsers].sort!.join(', ')
  if trim_line
    f.write "\"#{user_name}\":#{Oj.dump(user, mode: :compat)}"
  else
    f.write "\"#{user_name}\":#{Oj.dump(user, mode: :compat)},\n"
  end
end

def work(filename = '')
  puts "rss 1: #{print_memory_usage}"
  user_names = {}
  sessions = {}
  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: nil,
  }

  user = nil
  prev_id = nil
  current_id = nil
  user_name = nil

  File.open("result-2","w") do |f|
  File.open(filename).each do |line|
    cols = line.chomp.split(',')

    if cols[0] == 'user'
      if user
        write_temp_user(f, user_name, user)
      end
      report[:totalUsers] += 1
      user_name = cols[2].concat(' ', cols[3])
      user = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: false,
        dates: []
      }
    else
      cols[3].upcase!
      cols[4] = cols[4].to_i

      user[:sessionsCount] += 1
      user[:totalTime] += cols[4]
      user[:longestSession] = cols[4] if user[:longestSession] < cols[4]
      user[:browsers].push(cols[3])
      user[:dates].push(cols[5])

      sessions[cols[3]] = nil
      report[:totalSessions] += 1
    end
  end
  write_temp_user(f, user_name, user, true)
  end
  puts "rss 2: #{print_memory_usage}"

  report[:uniqueBrowsersCount] = sessions.keys.count
  report[:allBrowsers] = sessions
    .keys
    .sort!
    .join(',')

  puts "rss 4: #{print_memory_usage}"
  File.open("result.json","w") do |f|
    st = Oj.dump(report, mode: :compat)
    f.write st.delete_suffix('}')
    puts "rss 5: #{print_memory_usage}"
    f.write ",\"usersStats\":{"
    puts "rss 6: #{print_memory_usage}"
    File.open("result-2").each do |line|
      f.write line.chomp
    end
    puts "rss 7: #{print_memory_usage}"
    f.write "}}"
    f.write "\n"
  end

  puts "rss 8: #{print_memory_usage}"
end
