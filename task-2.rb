# Deoptimized version of homework task

require 'set'
require 'oj'

def summarize_user(file, user_key, user_stat, last = false)
  user_stat[:totalTime] = "#{user_stat[:totalTime]} min."
  user_stat[:longestSession] = "#{user_stat[:longestSession]} min."
  user_stat[:browsers] = user_stat[:browsers].sort!.join(', ')
  user_stat[:dates] = user_stat[:dates].sort!.reverse!

  file << '"' << user_key << '":'
  file << Oj.dump(user_stat, mode: :compat)
  file << ',' unless last
end

def work(filename, disable_gc: false)
  GC.disable if disable_gc

  report = {
    totalUsers: 0,
    uniqueBrowsersCount: 0,
    totalSessions: 0,
    allBrowsers: nil,
    usersStats: {},
  }

  unique_browsers = Set.new
  user_key = nil
  first_session_flag = false
  user_stat = {
    sessionsCount: 0,
    totalTime: 0,
    longestSession: 0,
    browsers: [],
    usedIE: false,
    alwaysUsedChrome: false,
    dates: [],
  }

  result_file = File.open('result.json', 'w')
  result_file.write('{"usersStats":{')

  File.open(filename).each_line do |line|
    # a, b, *c = "1,2,3,4,5".split(',', 2); [a,b,c] # => ["1", "2,3,4,5", []]
    # a, b, *c = "1,2,3,4,5".split(',', -2); [a,b,c] # => ["1", "2", ["3", "4", "5"]]

    if line.start_with?('user')
      _, _, first_name, last_name = line.chomp!.split(',', -5)
      report[:totalUsers] += 1

      summarize_user(result_file, user_key, user_stat) if user_key
      first_session_flag = true

      user_key = "#{first_name} #{last_name}"
      user_stat[:sessionsCount] = 0
      user_stat[:totalTime] = 0
      user_stat[:longestSession] = 0
      user_stat[:browsers] = []
      user_stat[:usedIE] = false
      user_stat[:alwaysUsedChrome] = false
      user_stat[:dates] = []
    elsif line.start_with?('session')
      _, _, _, browser, time, date = line.chomp!.split(',', -6)
      time = time.to_i
      browser = browser.upcase!

      report[:totalSessions] += 1
      user_stat[:sessionsCount] += 1
      user_stat[:totalTime] += time
      user_stat[:longestSession] = time if user_stat[:longestSession] < time
      user_stat[:browsers] << browser
      user_stat[:usedIE] = true if !user_stat[:usedIE] && browser.start_with?('INTERNET EXPLORER')
      user_stat[:alwaysUsedChrome] = true if first_session_flag
      user_stat[:alwaysUsedChrome] = false unless user_stat[:alwaysUsedChrome] && browser.start_with?('CHROME')
      user_stat[:dates] << date
      unique_browsers.add(browser)

      first_session_flag = false
    end
  end
  summarize_user(result_file, user_key, user_stat, true)

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

  # Подсчёт количества уникальных браузеров
  report[:uniqueBrowsersCount] = unique_browsers.count
  report[:allBrowsers] = unique_browsers.sort.join(',')

  result_file << '},'
  result_file << '"totalUsers":' << report[:totalUsers] << ','
  result_file << '"uniqueBrowsersCount":' << report[:uniqueBrowsersCount] << ','
  result_file << '"totalSessions":' << report[:totalSessions] << ','
  result_file << '"allBrowsers":"' << report[:allBrowsers] << '"'
  result_file.write('}')
  result_file.close
  # File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
