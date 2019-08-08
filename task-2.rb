# frozen_string_literal: true

require 'set'
require 'json'
require 'date'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
BROWSERS = %w[CHROME INTERNET\ EXPLORER].freeze

def work(file)
  filer   = File.new('result.json', 'w')
  report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: Set.new, usersStats: {} }

  File.foreach(file) do |line|
    is_user = line.include?(USER)
    @user = is_user ? user_name(line) : @user
    make_report(line, @user, is_user, report)
  end

  prepare_report(report)
  filer.write "#{report.to_json}\n"
  filer.close
end

private

def user_name(line)
  n = line.split(SPLIT)
  "#{n[2]} #{n[3]}"
end

def make_report(line, user, is_user = false, report)
  if is_user
    report[:usersStats][user] = { sessionsCount: 0,
                                   totalTime: 0,
                                   longestSession: 0,
                                   browsers: [],
                                   usedIE: false,
                                   alwaysUsedChrome: true,
                                   dates: ''.dup }
    report[:totalUsers] += 1
  else
    line.upcase!
    cols = line.split(SPLIT)
    i = 0

    while i < 6
      i += 1
      data = cols.shift

      case i
      when 4
        report[:allBrowsers] << data
        report[:usersStats][user][:alwaysUsedChrome] = false if !report[:usersStats][user][:alwaysUsedChrome] || !data.include?(BROWSERS[0])
        report[:usersStats][user][:usedIE] = true if report[:usersStats][user][:usedIE] || data.include?(BROWSERS[1])
        report[:usersStats][user][:browsers] << data
      when 5
        report[:usersStats][user][:totalTime] += data.to_i
        report[:usersStats][user][:longestSession] = data.to_i if report[:usersStats][user][:longestSession] < data.to_i
      when 6
        report[:usersStats][user][:dates] << " #{data.chomp}"
      end
    end

    report[:totalSessions] += 1
    report[:usersStats][user][:sessionsCount] += 1
  end
end

def prepare_report(report)
  report[:uniqueBrowsersCount] = report[:allBrowsers].length
  report[:allBrowsers]         = report[:allBrowsers].sort.join(SPLIT)

  report[:usersStats].each_value do |user|
    user[:totalTime]      = "#{user[:totalTime]} #{MIN}"
    user[:browsers].sort!
    user[:browsers]       = user[:browsers].join(COMMA)
    user[:longestSession] = "#{user[:longestSession]} #{MIN}"
    user[:dates]          = user[:dates].split(WS).sort!.reverse
  end
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

# work('data_large.txt')

# p print_memory_usage