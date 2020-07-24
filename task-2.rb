# Deoptimized version of homework task

require 'set'
require 'oj'

def summarize_user(user)
  user[:totalTime] = "#{user[:totalTime]} min."
  user[:longestSession] = "#{user[:longestSession]} min."

  user[:browsers] = user[:browsers].sort!.join(', ')
  user[:dates] = user[:dates].sort!.reverse!
end

def work(filename, disable_gc: false)
  GC.disable if disable_gc
  file_lines = File.read(filename).split("\n")

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

  file_lines.each do |line|
    # a, b, *c = "1,2,3,4,5".split(',', 2); [a,b,c] # => ["1", "2,3,4,5", []]
    # a, b, *c = "1,2,3,4,5".split(',', -2); [a,b,c] # => ["1", "2", ["3", "4", "5"]]

    if line.start_with?('user')
      _, _, first_name, last_name, _ = line.split(/[,\n]/, -5)
      report[:totalUsers] += 1

      summarize_user(report[:usersStats][user_key]) if user_key
      first_session_flag = true

      user_key = "#{first_name} #{last_name}"
      report[:usersStats][user_key] = {
        sessionsCount: 0,
        totalTime: 0,
        longestSession: 0,
        browsers: [],
        usedIE: false,
        alwaysUsedChrome: false,
        dates: [],
      }
    end
    if line.start_with?('session')
      _, _, _, browser, time, date = line.split(',', -6)
      time = time.to_i
      browser = browser.upcase!

      report[:totalSessions] += 1
      user_stat = report[:usersStats][user_key]
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
  summarize_user(report[:usersStats][user_key])

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
  report[:allBrowsers] = unique_browsers.map(&:upcase).sort.join(',')

  File.write('result.json', "#{Oj.dump(report, mode: :compat)}\n")
end
