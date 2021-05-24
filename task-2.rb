def parse_user(fields)
  {
    id: fields[1],
    first_name: fields[2],
    last_name: fields[3],
    age: fields[4],
  }
end

def parse_session(fields)
  {
    user_id: fields[1],
    session_id: fields[2],
    browser: fields[3].upcase,
    time: fields[4].to_i,
    date: fields[5],
  }
end

def sessions_hash
  { count: 0,
    totalTime: 0,
    sessionTimes: [],
    browsers: [],
    dates: [] }
end

def puts_user_data(user, report_file, sessions)
  report_file.print("\"#{user[:first_name]} #{user[:last_name]}\":{"\
                   "\"sessionsCount\":#{sessions[:count]},"\
                   "\"totalTime\":\"#{sessions[:totalTime]} min.\","\
                   "\"longestSession\":\"#{sessions[:sessionTimes].max} min.\","\
                   "\"browsers\":\"#{sessions[:browsers].sort.join(', ')}\","\
                   "\"usedIE\":#{sessions[:browsers].any? { |b| b.start_with?('I') }},"\
                   "\"alwaysUsedChrome\":#{sessions[:browsers].all? { |b| b.start_with?('C') }},"\
                   "\"dates\":#{sessions[:dates].sort.reverse}}")
end

def work(from_file, to_file)
  sessions = sessions_hash
  report = { totalUsers: 0,
             uniqueBrowsers: {},
             totalSessions: 0,
             allBrowsers: nil }

  report_file = File.new(to_file, 'w')
  report_file.print('{"usersStats":{')

  File.foreach(from_file) do |line|
    cols = line.strip.split(',')
    if cols[0] == 'user'
      if sessions[:count] > 0
        puts_user_data(@user, report_file, sessions)
        report_file.print(',')
        sessions = sessions_hash
      end

      @user = parse_user(cols)
      report[:totalUsers] += 1
    else
      session = parse_session(cols)
      sessions[:count] += 1
      sessions[:totalTime] += session[:time]
      sessions[:sessionTimes] << session[:time]
      sessions[:browsers] << session[:browser]
      sessions[:dates] << session[:date]

      report[:uniqueBrowsers][session[:browser]] ||= true
      report[:totalSessions] += 1
    end
  end

  puts_user_data(@user, report_file, sessions)

  report_file.print('}')
  report_file.print(",\"totalUsers\":#{report[:totalUsers]},"\
                   "\"uniqueBrowsersCount\":#{report[:uniqueBrowsers].keys.count},"\
                   "\"totalSessions\":#{report[:totalSessions]},"\
                   "\"allBrowsers\":\"#{report[:uniqueBrowsers].keys.sort.join(',')}\"}")
  report_file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
