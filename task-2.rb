# frozen_string_literal: true

require 'oj'

def parse_session(fields)
  {
    'browser' => fields[3].upcase!,
    'time' => fields[4].to_i,
    'date' => fields[5]
  }
end

$user = nil
$need_save_report = false
$sessions_count = 0
$total_users = 0
$total_sessions = 0
$unique_browsers = {}
$report = {}

$file = File.open('result.json', 'a')

def work(file_name = 'data.txt')
  save_report('{"usersStats":{')

  IO.foreach(file_name) do |line|
    line.strip!
    cols = line.split(',')

    if cols[0] == 'user'
      if $need_save_report
        update_user_stat
        $report = {}
      end

      $sessions_count = 0
      $user = "#{cols[2]} #{cols[3]}"
      $total_users += 1
    else
      $sessions_count += 1

      session = parse_session(cols)

      $total_sessions += 1
      $report[$user] ||= {}
      $report[$user]['sessionsCount'] = $sessions_count

      $report[$user]['totalTime'] ||= 0
      $report[$user]['totalTime'] += session['time']

      $report[$user]['longestSession'] ||= 0
      long_time = $report[$user]['longestSession']
      $report[$user]['longestSession'] = session['time'] if long_time < session['time']

      $report[$user]['browsers'] ||= []
      $report[$user]['browsers'] << session['browser']

      $report[$user]['usedIE'] ||= false
      $report[$user]['usedIE'] = true if session['browser'].start_with?('I')

      $report[$user]['dates'] ||= []
      $report[$user]['dates'] << session['date']

      $unique_browsers[session['browser']] = nil
      $need_save_report = true
    end
  end

  update_user_stat(true)
  save_total_report

  $file.close
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end


def save_report(data)
  $file.write(data)
end

def update_user_stat(last_user = false)
  browsers = $report[$user]['browsers'].sort!
  $report[$user]['browsers'] = browsers.join(', ')
  $report[$user]['alwaysUsedChrome'] = browsers.all? { |b| b.start_with?('C') }
  $report[$user]['dates'].sort!.reverse!
  $report[$user]['totalTime'] = "#{$report[$user]['totalTime']} min."
  $report[$user]['longestSession'] = "#{$report[$user]['longestSession']} min."

  save_report Oj.dump($report)[1...-1] << (last_user ? '},' : ',')
end

def save_total_report
  $unique_browsers = $unique_browsers.keys.uniq.sort!

  save_report Oj.dump({
    'totalUsers' => $total_users,
    'uniqueBrowsersCount' => $unique_browsers.size,
    'totalSessions' => $total_sessions,
    'allBrowsers' => $unique_browsers.join(',')
  })[1..-1]
end