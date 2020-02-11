# Deoptimized version of homework task
#frozen_string_literal: true
require 'oj'
require 'pry'
require 'date'
require 'ruby-prof'
require 'stackprof'

require 'ruby-progressbar'

Dir[File.join(__dir__, 'class', '*.rb')].each { |file| require file }


COMMA = ','
SPACE = ' '
USER  = 'user'
COMMA_SPACE = ', '
SAPCE_MIN = ' min.'
EMPTY = ''
NEW_LINE =  "\n"
FILE_TO_WRITE = 'result.json'

def work(file)
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

  @user_count = 0
  @unique_browsers = []
  @total_sessions = 0
  @total_time = 0
  user = nil
  sessions =[]

  File.open(FILE_TO_WRITE, 'w') do |f|
    f << ('{"usersStats":{')

    File.foreach(file).each do |line|

      fields = line.split(COMMA)

      if line.start_with?(USER)
        write_user_info(user, sessions, true, f) if user
        sessions = []
        user = parse_user(fields)
        @user_count += 1
      else
        browser = fields[3].upcase

        sessions << {
          browser: browser,
          time: fields[4].to_i,
          date: fields[5].chomp
        }
        @unique_browsers << browser

        @total_sessions += 1
        @total_time += fields[4].to_i
      end
    end

    write_user_info(user, sessions, false, f)

    sessions = []

    f << ('},')
    f << (Oj.dump({
      'totalUsers'=> @user_count,
      'uniqueBrowsersCount'=> @unique_browsers.uniq.count,
      'totalSessions'=> @total_sessions,
      'allBrowsers'=> @unique_browsers.uniq!.sort!.join(COMMA)
    })[1..])
  end
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(fields)
  {
    first_name: fields[2],
    last_name: fields[3]
  }
end

def write_user_info(user, sessions, need_separator, f)
  f << ("\"#{user[:first_name]} {#{user[:last_name]}\":")

  f << (Oj.dump({
    'sessionsCount'=> sessions.count,
    'totalTime'=> sessions.map { |s| s[:time] }.sum.to_s << SAPCE_MIN,
    'longestSession'=>  sessions.map { |s| s[:time] }.max.to_s << SAPCE_MIN,
    'browsers'=> sessions.map { |s| s[:browser] }.sort!.join(COMMA_SPACE),
    'usedIE'=>  sessions.map { |s| s[:browser] }.any? { |b| b =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome'=>  sessions.map { |s| s[:browser] }.all? { |b| b =~ /CHROME/ },
    'dates'=> sessions.map { |s| s[:date] }.sort!.reverse!
  }))

  f << (COMMA) if need_separator
end
