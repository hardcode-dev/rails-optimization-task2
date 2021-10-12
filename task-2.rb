# frozen_string_literal: true

require 'json'
require 'date'
require 'set'
require 'byebug'

COMMA = ','
COMMA_WITH_SPACE = ', '
USER_START = 'u'
MIN_SUFFIX = ' min.'

def parse_session(fields)
  {
    browser: fields[3].upcase!,
    time: fields[4].to_i,
    date: fields[5].chomp!
  }
end

def collect_stats(sessions)
  browsers = sessions.map { |s| s[:browser] }

  {
    sessionsCount: sessions.count,
    totalTime: "#{sessions.sum { |s| s[:time] }}#{MIN_SUFFIX}",
    longestSession: "#{sessions.map { |s| s[:time] }.max}#{MIN_SUFFIX}",
    browsers: browsers.sort!.join(COMMA_WITH_SPACE),
    usedIE: browsers.any? { |b| b.include?('INTERNET EXPLORER') },
    alwaysUsedChrome: browsers.none? { |s| s !~ /CHROME/ },
    dates: sessions.map! { |s| s[:date] }.sort! { |a, b| b <=> a }
  }
end

def write_to_file(user, sessions, separator = COMMA)
  @file.write({ user => collect_stats(sessions) }.to_json[1..-2])
  @file.write(separator)
end

def work(filename)
  result = {
    totalUsers: 0,
    totalSessions: 0,
    allBrowsers: Set[],
    uniqueBrowsersCount: 0
  }

  current_user = nil
  sessions = []

  @file = File.open('result.json', 'w+')
  @file.write('{"usersStats":{')

  File.foreach(filename) do |line|
    write_to_file(current_user, sessions) if current_user && line.start_with?(USER_START)

    if line.start_with?(USER_START)
      result[:totalUsers] += 1
      current_user = "#{line.split(COMMA)[2]} #{line.split(COMMA)[3]}"
      sessions = []
    else
      result[:totalSessions] += 1

      session = parse_session(line.split(COMMA))
      result[:uniqueBrowsersCount] += 1 if result[:allBrowsers].add?(session[:browser])
      sessions << session
    end
  end

  write_to_file(current_user, sessions, '')
  result[:allBrowsers] = result[:allBrowsers].sort.join(COMMA)
  @file.write('},')
  @file.write(result.to_json[1..])
  @file.close

  # puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

# work(ENV['DATA_FILE'] || 'data.txt') if ENV['APP_ENV'] != 'test'
