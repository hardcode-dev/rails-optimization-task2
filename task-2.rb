# frozen_string_literal: true

require 'set'
require 'json'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
DIGIT = /[\d-]{1,}/.freeze
REG_BROWSERS = {
    'CHROME'            => /(CHROME)\s(\d{1,})/m,
    'INTERNET EXPLORER' => /(INTERNET EXPLORER)\s(\d{1,})/m,
    'FIREFOX'           => /(FIREFOX)\s(\d{1,})/m,
    'SAFARI'            => /(SAFARI)\s(\d{1,})/m
}.freeze


def work(file)
  filer   = File.new('result.json', 'w')
  @report = { totalUsers: 0, uniqueBrowsersCount: 0, totalSessions: 0, allBrowsers: Set.new, usersStats: {} }
  @user   = ''

  File.foreach(file) do |line|
    is_user = line.include?(USER)
    @user = is_user ? line.split(SPLIT)[2..3].join(WS) : @user
    make_report(line, @user, is_user)
  end

  prepare_report
  filer.write "#{@report.to_json}\n"
  filer.close
end

private

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

    report_by_session(user, line)
  end
end

def report_by_session(user, line)
  @report[:allBrowsers] << "#{fetch_browser(line)} #{fetch_version(line)}"
  @report[:totalSessions] += 1

  @report[:usersStats][user][:sessionsCount] += 1
  @report[:usersStats][user][:alwaysUsedChrome] = false if !@report[:usersStats][user][:alwaysUsedChrome] || !line.include?(REG_BROWSERS.keys[0])
  @report[:usersStats][user][:usedIE] = true if @report[:usersStats][user][:usedIE] || line.include?(REG_BROWSERS.keys[1])
  @report[:usersStats][user][:browsers] << "#{fetch_browser(line)} #{fetch_version(line)}"

  cols = line.scan(DIGIT)
  @report[:usersStats][user][:totalTime][0] += cols[3].to_i
  @report[:usersStats][user][:longestSession][0] = cols[3].to_i if @report[:usersStats][user][:longestSession][0] < cols[3].to_i
  @report[:usersStats][user][:dates] << cols[4]
end

def fetch_date(line)
  line.scan(DIGIT)[4]
end

def fetch_time(line)
  line.scan(DIGIT)[3].to_i
end

def fetch_version(line)
  REG_BROWSERS[fetch_browser(line)].match(line)[2]
end

def fetch_browser(line)
  REG_BROWSERS.keys.find{|b| line.include? b}
end

def prepare_report
  @report[:uniqueBrowsersCount] = @report[:allBrowsers].length
  @report[:allBrowsers]         = browser_decoration(@report[:allBrowsers])

  @report[:usersStats].each_value do |user|
    user[:totalTime]      = user[:totalTime].join(WS)
    user[:browsers]       = user[:browsers].sort.join(COMMA)
    user[:longestSession] = user[:longestSession].join(WS)
    user[:dates]          = user[:dates].sort.reverse
  end
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

work('data-500.txt')

sleep 15
p print_memory_usage
