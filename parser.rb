require 'json'
# require 'pry'
require 'date'
require_relative 'user'

class Parser
  def initialize(disable_gc: false)
    GC.disable if disable_gc
    @report = set_report_struct
  end

  def work(file)
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
        user_stats['dates'] << session['date']
      end
    end

    @report['uniqueBrowsersCount'] = @report['allBrowsers'].uniq!.sort!.count
    @report['allBrowsers'] = @report['allBrowsers'].join(',')

    @report['usersStats'].each_value do |value|
      value['browsers'] = value['browsers'].sort.join(', ')
      value['dates'] = value['dates'].map { |d| Date.parse(d) }.sort.reverse.map(&:iso8601)
      value['totalTime'] = value['totalTime'].to_s + ' min.'
      value['longestSession'] = value['longestSession'].to_s + ' min.'
    end


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

    ### REPORT
    # Кол-во юзеров
    # @report['totalUsers'] = @users.count
    #
    # # Кол-во уникальных браузеров
    # unique_browsers = @sessions.map do |session|
    #   session['browser']
    # end.uniq
    #
    # @report['uniqueBrowsersCount'] = unique_browsers.count
    #
    # # Кол-во сессий
    # @report['totalSessions'] = @sessions.count
    #
    # # Униикальные браузеры в алфавитном порядке через запятую и капсом
    # @report['allBrowsers'] = unique_browsers.sort.join(',').upcase
    #
    # ## Статистика по пользователям
    # collect_stats_from_users do |user|
    #   user_sessions = @sessions.select { |session| session['user_id'] == user['id'] }
    #
    #   {
    #     # Кол-во сессий по пользователю
    #     'sessionsCount' => user_sessions.count,
    #
    #     # Кол-во времени по пользователям
    #     'totalTime' => user_sessions.map {|s| s['time']}.map(&:to_i).sum.to_s + ' min.',
    #
    #     # Самая длинная сессия пользователя
    #     'longestSession' => user_sessions.map {|s| s['time']}.map(&:to_i).max.to_s + ' min.',
    #
    #     # Браузеры пользователя через запятую
    #     'browsers' => user_sessions.map {|s| s['browser']}.map(&:upcase).sort.join(', '),
    #
    #     # Хоть раз использовал IE?
    #     'usedIE' => user_sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    #
    #     # Всегда использовал только Chrome?
    #     'alwaysUsedChrome' => user_sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
    #
    #     # Даты сессий через запятую в обратном порядке в формате iso8601
    #     'dates' => user_sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map(&:iso8601)
    #   }
    # end

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

Parser.new.work('data/data10_000.txt')
