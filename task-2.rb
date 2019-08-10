# frozen_string_literal: true

require 'set'
require 'oj'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
BROWSERS = %w[CHROME INTERNET\ EXPLORER].freeze

def work(file)
  result_file = File.new('result.json', 'w')
  tmp_file   = File.new('.result.tmp', 'a:UTF-8')
  report = { 'totalUsers' => 0, 'uniqueBrowsersCount' => 0, 'totalSessions' => 0, 'allBrowsers' => Set.new, 'usersStats' => {} }

  last_string = `wc -l #{file}`.split(WS)[0].to_i
  current_string = 0

  File.foreach(file) do |line|
    current_string += 1
    is_user = line.include?(USER)
    @user  = is_user ? user_name(line) : @user
    make_report(line, @user, is_user, report)

    save_interim_report(report, tmp_file, last_string, current_string)
  end

  prepare_user_report(report)

  aggregation_browser_data(report)
  result_file.write "#{Oj.dump(report)}\n"

  result_file.close
  tmp_file.close
end

private

def save_interim_report(report, tmp_file, last_string, current_string)
  return unless last_string == current_string || report['usersStats'].keys.length > 1

  user_name   = report['usersStats'].keys[0]
  user_report = report['usersStats'][user_name]
  tmp_file.write("\"#{user_name}\":#{Oj.dump(user_report)} \r")
  report['usersStats'].tap { |users| users.delete(user_name) }
end

def user_name(line)
  n = line.split(SPLIT)
  "#{n[2]} #{n[3]}"
end

def browser_decoration(browsers)
  browsers.sort.join(SPLIT)
end

def make_report(line, user, is_user = false, report)
  if is_user
    report['usersStats'][user] = { 'sessionsCount' => 0,
                                   'totalTime' => 0,
                                   'longestSession' => 0,
                                   'browsers' => [],
                                   'usedIE' => false,
                                   'alwaysUsedChrome' => true,
                                   'dates' => ''.dup }
    report['totalUsers'] += 1
  else
    line.upcase!
    cols = line.split(SPLIT)
    i = 0

    while i < 6
      i += 1
      data = cols.shift

      case i
      when 4
        report['allBrowsers'] << data
        report['usersStats'][user]['alwaysUsedChrome'] = false if !report['usersStats'][user]['alwaysUsedChrome'] || !data.include?(BROWSERS[0])
        report['usersStats'][user]['usedIE'] = true if report['usersStats'][user]['usedIE'] || data.include?(BROWSERS[1])
        report['usersStats'][user]['browsers'] << data
      when 5
        report['usersStats'][user]['totalTime'] += data.to_i
        report['usersStats'][user]['longestSession'] = data.to_i if report['usersStats'][user]['longestSession'] < data.to_i
      when 6
        report['usersStats'][user]['dates'] << " #{data.chomp}"
      end
    end

    report['totalSessions'] += 1
    report['usersStats'][user]['sessionsCount'] += 1
  end
end

def aggregation_browser_data(report)
  report['uniqueBrowsersCount'] = report['allBrowsers'].length
  report['allBrowsers']         = report['allBrowsers'].sort.join(SPLIT)
end

def prepare_user_report(report)
  report['usersStats'].each_value do |user|
    user['totalTime']      = "#{user['totalTime']} #{MIN}"
    user['browsers'].sort!
    user['browsers']       = user['browsers'].join(COMMA)
    user['longestSession'] = "#{user['longestSession']} #{MIN}"
    user['dates']          = user['dates'].split(WS).sort!.reverse
  end
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

work('data_large.txt')

p print_memory_usage       # 959 MB