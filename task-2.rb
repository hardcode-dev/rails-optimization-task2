# frozen_string_literal: true

# Optimized version of homework task
require 'pry'
require 'set'
require 'oj'

def parse_user(user)
  {
    'id' => user[1],
    'first_name' => user[2],
    'last_name' => user[3],
    'full_name' => "#{user[2]} #{user[3]}",
    'age' => user[4],
  }
end

def parse_session(session)
  {
    'user_id' => session[1],
    'session_id' => session[2],
    'browser' => session[3].upcase,
    'time' => session[4].to_i,
    'date' => session[5]
  }
end

def work(file_name:, disable_gc: false)
  GC.disable if disable_gc

  @user = nil
  @user_session = []
  @total_user_count = 0
  @total_session_count = 0
  @all_browsers = SortedSet.new
  @report_file = File.new('result.json', 'w')
  @report_file.write('{"usersStats":{')

  File.foreach(file_name, "\n", chomp: true) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      fill_user_data(user: @user, user_session: @user_session) if @user

      @user = parse_user(cols)
      @user_session = []
      @total_user_count += 1
    else
      @user_session << parse_session(cols)
      @total_session_count += 1

      @all_browsers << @user_session.last['browser'] unless @all_browsers.include?(@user_session.last['browser'])
    end
  end
  fill_user_data(user: @user, user_session: @user_session, last_user: true)

  last_report_data!

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
  # File.write('result.json', "#{test_report.to_json}\n")
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def fill_user_data(user:, user_session:, last_user: false)
  times = Set.new
  browsers = [] # оставил массив, так как Set.new дает только уникальные записи
  dates = SortedSet.new
  user_session.each do |session|
    times << session['time']
    browsers << session['browser'].upcase
    dates << session['date']
  end

  user_report = {
    # Собираем количество сессий по пользователям
    'sessionsCount' => user_session.size,
    # Собираем количество времени по пользователям
    'totalTime' => "#{times.sum} min.",
    # Выбираем самую длинную сессию пользователя
    'longestSession' => "#{times.max} min.",
    # Браузеры пользователя через запятую
    'browsers' => browsers.to_a.sort.join(', '),
    # Хоть раз использовал IE?
    'usedIE' => browsers.to_a.any? { |b| b =~ /INTERNET EXPLORER/ },
    # Всегда использовал только Chrome?
    'alwaysUsedChrome' => browsers.to_a.all? { |b| b =~ /CHROME/ },
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => dates.to_a.reverse
  }

  @report_file.write("\"#{user['full_name']}\":#{Oj.dump user_report}")
  @report_file.write(',') unless last_user
end
def last_report_data!
  @report_file.write("},\"totalUsers\":#{@total_user_count},\"uniqueBrowsersCount\":#{@all_browsers.size},\"totalSessions\":#{@total_session_count},\"allBrowsers\":\"#{ @all_browsers.to_a.join(',')}\"}")
  @report_file.close
end