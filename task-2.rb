# frozen_string_literal: true

require 'multi_json'
require 'set'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
IE = 'INTERNET EXPLORER'
CHROME = 'CHROME'

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
  filer.write "#{MultiJson.dump(@report)}\n"
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
    cols = line.split(SPLIT).last(3)
    @report[:totalSessions] += 1
    @report[:allBrowsers].add(cols[0])

    @report[:usersStats][user][:sessionsCount] += 1
    @report[:usersStats][user][:browsers] << cols[0]
    @report[:usersStats][user][:usedIE] = true if @report[:usersStats][user][:usedIE] || cols[0].include?(IE)
    @report[:usersStats][user][:alwaysUsedChrome] = false if !@report[:usersStats][user][:alwaysUsedChrome] || !cols[0].include?(CHROME)
    @report[:usersStats][user][:dates] << cols[2].chomp
    @report[:usersStats][user][:totalTime][0] += cols[1].to_i
    @report[:usersStats][user][:longestSession][0] = cols[1].to_i if @report[:usersStats][user][:longestSession][0] < cols[1].to_i
  end
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
