require 'json'
# require 'pry'
require 'date'

class Parser
  def initialize(disable_gc: false)
    GC.disable if disable_gc
    @report = set_report_struct
  end

  def work(file)
    # Отчёт в json
    #   - Сколько всего юзеров +
    #   - Сколько всего уникальных браузеров +
    #   - Сколько всего сессий +
    #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
    #
    #   - По каждому пользователю
    #     - сколько всего сессий +
    #     - сколько всего времени +
    #     - самая длинная сессия +
    #     - браузеры через запятую +
    #     - Хоть раз использовал IE? +
    #     - Всегда использовал только Хром? +
    #     - даты сессий в порядке убывания через запятую +

    File.foreach(file, chomp: true) do |line|
      line = line.split(',')

      if line[0] == 'user'
        @report['totalUsers'] += 1
        @user = parse_user(line)
      end

      user_key = "#{@user['first_name']} #{@user['last_name']}"
      user_stats = @report['usersStats'][user_key] ||= set_user_stats_report_struct

      if line[0] == 'session' && line[1] == @user['id']
        session = parse_session(line)

        # Stats
        @report['totalSessions'] += 1
        @report['allBrowsers'] << session['browser'].upcase!

        # UserStats
        user_stats['sessionsCount'] += 1
        user_stats['totalTime'] += session['time']
        user_stats['longestSession'] = session['time'] if session['time'] > user_stats['longestSession']
        user_stats['browsers'] << session['browser']
        user_stats['usedIE'] = true if /INTERNET EXPLORER/.match?(session['browser'])
        user_stats['alwaysUsedChrome'] = false unless /CHROME/.match?(session['browser'])
        user_stats['dates'] << Date.strptime(session['date'], '%Y-%m-%d').iso8601
      end
    end

    @report['uniqueBrowsersCount'] = @report['allBrowsers'].uniq!.sort!.count
    @report['allBrowsers'] = @report['allBrowsers'].join(',')

    @report['usersStats'].each_value do |value|
      value['browsers'] = value['browsers'].sort.join(', ')
      value['dates'].sort!.reverse!
      value['totalTime'] = value['totalTime'].to_s + ' min.'
      value['longestSession'] = value['longestSession'].to_s + ' min.'
    end

    File.write('data/result.json', "#{@report.to_json}\n")

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  private

  def set_report_struct
    {
      'totalUsers' => 0,
      'uniqueBrowsersCount' => 0,
      'totalSessions' => 0,
      'allBrowsers' => [],
      'usersStats' => {}
    }
  end

  def set_user_stats_report_struct
    {
      'sessionsCount' => 0,
      'totalTime' => 0,
      'longestSession' => 0,
      'browsers' => [],
      'usedIE' => false,
      'alwaysUsedChrome' => false,
      'dates' => []
    }
  end

  def parse_user(user)
    {
      'id' => user[1],
      'first_name' => user[2],
      'last_name' => user[3]
    }
  end

  def parse_session(session)
    {
      'user_id' => session[1],
      'session_id' => session[2],
      'browser' => session[3],
      'time' => session[4].to_i,
      'date' => session[5]
    }
  end
end
