# frozen_string_literal: true

require 'json'
require 'oj'
require 'minitest/autorun'
require 'set'

def work(file_name)
  GC.enable
  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
  @user_is_first = true
  default_settings
  add_to_report('{"usersStats":{')

  File.open(file_name, 'r').each do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user_action(cols)
    else
      sessions_action(cols)
    end
  end

  send_to_report

  @report['allBrowsers']
  @report['uniqueBrowsersCount'] = @report['allBrowsers'].count
  @report['allBrowsers'] = @report['allBrowsers'].to_a.join(',')

  add_to_report("},\"totalUsers\":#{@report['totalUsers']},")
  add_to_report("\"totalSessions\":#{@report['totalSessions']},")
  add_to_report("\"uniqueBrowsersCount\":#{@report['uniqueBrowsersCount']},")
  add_to_report("\"allBrowsers\":\"#{@report['allBrowsers']}\"}")
  @report_file.close

  puts format('MEMORY USAGE: %d MB', (`ps -o rss= -p #{Process.pid}`.to_i / 1024))
end

def default_settings
  @report_file = File.open('result.json', 'a')
  @report = {}
  @report['totalUsers'] = 0
  @report['uniqueBrowsersCount'] = 0
  @report['totalSessions'] = 0
  @report['allBrowsers'] = SortedSet[]
end

def user_action(cols)
  send_to_report if @temp_user
  @temp_user = {
    'user_key' => "#{cols[2]} #{cols[3]}",
    'sessionsCount' => 0,
    'longestSession' => 0,
    'totalTime' => 0,
    'browsers' => [],
    'dates' => SortedSet[],
    'usedIE' => false,
    'alwaysUsedChrome' => true
  }

  @report['totalUsers'] += 1
end

def sessions_action(cols)
  @temp_user['sessionsCount'] += 1
  time = cols[4].to_i
  browser = cols[3]
  @temp_user['totalTime'] += time
  @temp_user['longestSession'] = time if @temp_user['longestSession'] <= time

  @temp_user['dates'] << cols[5].delete!("\n")

  @temp_user['browsers'] << browser.upcase

  @temp_user['usedIE'] = true if browser =~ /Internet Explorer/
  @temp_user['alwaysUsedChrome'] = false unless browser =~ /Chrome/

  @report['allBrowsers'].add(browser.upcase)

  @report['totalSessions'] += 1
end

def send_to_report
  user_key = @temp_user['user_key']
  user_report = { 'sessionsCount' => @temp_user['sessionsCount'],
                  'totalTime' => "#{@temp_user['totalTime']} min.",
                  'longestSession' => "#{@temp_user['longestSession']} min.",
                  'browsers' => @temp_user['browsers'].sort!.join(', '),
                  'usedIE' => @temp_user['usedIE'],
                  'alwaysUsedChrome' => @temp_user['alwaysUsedChrome'],
                  'dates' => @temp_user['dates'].to_a.reverse }

  text = if @user_is_first
           "\"#{user_key}\":#{Oj.dump(user_report)}"
         else
           ",\"#{user_key}\":#{Oj.dump(user_report)}"
         end
  @temp_user = {}
  @user_is_first = false
  add_to_report(text)
end

def add_to_report(text)
  @report_file.write(text)
end
