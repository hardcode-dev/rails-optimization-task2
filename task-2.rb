# frozen_string_literal: true

require 'set'
require 'json'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
BROWSERS = %w[CHROME INTERNET\ EXPLORER].freeze

def work(file)
  filer   = File.new('result.json', 'w')
  @report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: Set.new, usersStats: {} }

  File.foreach(file) do |line|
    is_user = line.include?(USER)
    @user = is_user ? user_name(line) : @user
    make_report(line, @user, is_user)
  end

  prepare_report
  filer.write "#{@report.to_json}\n"
  filer.close
end

private

def user_name(line)
  n = line.split(SPLIT)
  "#{n[2]} #{n[3]}"
end

def browser_decoration(browsers)
  browsers.sort.join(SPLIT)
end

def make_report(line, user, is_user = false)
  if is_user
    @report[:usersStats][user] = { sessionsCount: 0,
                                   totalTime: [0, MIN],
                                   longestSession: [0, MIN],
                                   browsers: [],
                                   usedIE: false,
                                   alwaysUsedChrome: true,
                                   dates: [] }
    @report[:totalUsers] += 1
  else
    line.upcase!
    cols = line.split(SPLIT)
    i = 0

    while i < 6
      i += 1
      data = cols.shift

      case i
      when 4
        @report[:allBrowsers] << data
        @report[:usersStats][user][:alwaysUsedChrome] = false if !@report[:usersStats][user][:alwaysUsedChrome] || !data.include?(BROWSERS[0])
        @report[:usersStats][user][:usedIE] = true if @report[:usersStats][user][:usedIE] || data.include?(BROWSERS[1])
        @report[:usersStats][user][:browsers] << data
      when 5
        @report[:usersStats][user][:totalTime][0] += data.to_i
        @report[:usersStats][user][:longestSession][0] = data.to_i if @report[:usersStats][user][:longestSession][0] < data.to_i
      when 6
        @report[:usersStats][user][:dates] << data.chomp
      end
    end

    @report[:totalSessions] += 1
    @report[:usersStats][user][:sessionsCount] += 1
  end
end

def prepare_report
  @report[:uniqueBrowsersCount] = @report[:allBrowsers].length
  @report[:allBrowsers]         = browser_decoration(@report[:allBrowsers])

  @report[:usersStats].each_value do |user|
    user[:totalTime]      = user[:totalTime].join(WS)
    user[:browsers].sort!
    user[:browsers]       = user[:browsers].join(COMMA)
    user[:longestSession] = user[:longestSession].join(WS)
    user[:dates]          = user[:dates].sort {|a,b| b<=>a}
  end
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

# work('data_large.txt')

# p print_memory_usage