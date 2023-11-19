require 'json'
require 'pry'
require 'date'

def append_to_file_json_start
  @report_file.write("{\"usersStats\":{")
end

def user_data?(data_array)
  data_array[0] == 'user'
end

def parse_new_user(data_array)
  @report[:totalUsers] += 1
  @user = {
    id: data_array[1],
    name: "#{data_array[2]} #{data_array[3]}",
    sessions: []
  }
end

def parse_session(data_array)
  @report[:totalSessions] += 1
  @user_sessions << {
    browser: data_array[3].upcase,
    time: data_array[4].to_i,
    date: data_array[5]
  }
end

def append_previous_user
  @user_data = { @user[:name] => collect_statisticss_from_sessions }
  @report_file.write("#{@user_data.to_json[1..-2]}", ',')
  @user_sessions = []
  @user_data = {}
end

def append_last_user
  @user_data = { @user[:name] => collect_statisticss_from_sessions }
  @report_file.write("#{@user_data.to_json[1..-2]}", '}')
end

def sessions_data_present?
  !@user_sessions.empty?
end

def append_total_data
  @report[:allBrowsers] = @report[:allBrowsers].sort!.join(',')
  @report_file.write(',', "#{@report.to_json[1..-1]}")
end

def work(filename = 'data_large.txt')
  file = File.open(filename)

  @user_sessions = []
  @user = {}
  @report_file = File.open('result.json', 'a')
  @report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: []
  }

  append_to_file_json_start
  file.each_line(chomp: true) do |line|
    cols = line.split(',')
    if user_data?(cols) && sessions_data_present?
      append_previous_user
      parse_new_user(cols)
    elsif user_data?(cols)
      parse_new_user(cols)
    else
      parse_session(cols)
    end
  end
  append_last_user

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

  append_total_data
  @report_file.close

  `ps -o rss= -p #{Process.pid}`.to_i / 1024
end

def collect_statisticss_from_sessions
  result = {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: false,
    dates: []
  }
  @user_sessions.each do |session|
    time = session[:time]
    result[:totalTime] += time
    result[:longestSession] = time if time > result[:longestSession]
    browser = session[:browser]
    unless @report[:allBrowsers].include?(browser)
      @report[:allBrowsers] << browser
      @report[:uniqueBrowsersCount] += 1
    end
    result[:browsers] << browser
    result[:usedIE] = true if !(browser =~ /INTERNET EXPLORER/).nil?
    result[:alwaysUsedChrome] = !(browser =~ /CHROME/).nil? && (result[:sessionsCount] == 0 || result[:alwaysUsedChrome])
    result[:dates] << session[:date]
    result[:sessionsCount] += 1
  end
  result[:totalTime] = result[:totalTime].to_s + ' min.'
  result[:longestSession] = result[:longestSession].to_s + ' min.'
  result[:browsers] = result[:browsers].sort!.join(', ')
  result[:dates].sort!.reverse!
  result
end
