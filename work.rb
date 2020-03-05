USER = 'user,'
COMMA = ','
COMMA_SPACE = ', '
TRUES = 'true'
FALSES = 'false'
IE = 'INTERNET EXPLORER'
CHROME = 'CHROME'
ES = ''
SPACE = ' '

def report_user(user, sessions)

  browsers, times, dates = sessions.transpose

  @output.write(
             "#{@user_count > 0 ? COMMA : ES}\"#{user}\":{\"sessionsCount\":#{sessions.size},\"totalTime\":\"#{times.sum} min.\",\"longestSession\":\"#{times.max} min.\",\"browsers\":\"#{browsers.sort.join(COMMA_SPACE)}\",\"usedIE\":#{browsers.any?{ |b| b.start_with?(IE) } ? TRUES : FALSES},\"alwaysUsedChrome\":#{browsers.all?{ |b| b.start_with?(CHROME) }  ? TRUES : FALSES},\"dates\":#{dates.sort.reverse}}")
  @user_count += 1
  @session_count += sessions.size
  @unique_browsers += browsers
  @unique_browsers.uniq!
end

def work(source_data_file = 'data.txt', disable_gc = false)

  GC.disable if disable_gc

  @session_count = 0
  @user_count = 0
  @unique_browsers = []
  @output = File.open('result.json', mode: 'w+')

  @output.write('{"usersStats":{') #, mode: "a"

  user = ES
  sessions = []

  File.open(source_data_file, 'r') do |f|
    while line = f.gets
      if line.start_with?(USER)
        report_user(user, sessions) unless sessions.empty?
        line[0..5] = ES
        user = line.split(COMMA)[1..2].join(SPACE)
        sessions = []
      else
        line[0..7] = ES
        browser, time, date = *line.split(COMMA)[2..4]
        sessions << [browser.upcase, time.to_i, date.strip]
      end
    end
    report_user(user, sessions) unless sessions.empty?
  end
  @output.write('},')

  @output.write(
             "\"totalUsers\":#{@user_count}, \"uniqueBrowsersCount\":#{@unique_browsers.size}, \"totalSessions\":#{@session_count}, \"allBrowsers\":\"#{@unique_browsers.sort.join(COMMA)}\"}\n")
  @output.close
  puts "MEMORY USAGE: %d KB" % (`ps -o rss= -p #{Process.pid}`.to_i)
end

# time1 = Time.now.to_i
#
# ARGV[0] ? work(ARGV[0]) : work
#
# puts "Work time: %d s" % (Time.now.to_i - time1.to_i)
