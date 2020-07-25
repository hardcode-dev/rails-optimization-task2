# frozen_string_literal: true
# Deoptimized version of homework task

require 'set'
require 'oj'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end
end

def parse_user(user)
  fields = user.split(',')

  {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')

  {
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def collect_stats_from_users(user)
  report = {}

  user_key = "#{user.attributes['first_name']} #{user.attributes['last_name']}"
  report[user_key] ||= {}

  session_times = []
  session_browsers = []
  session_dates = []

  use_ie = false
  all_times_use_chrome = true
  user_sessions_cn = 0

  while user.sessions.size > 0
    session = user.sessions.shift
    browser = session['browser'].upcase
    session_times << session['time'].to_i
    session_browsers << browser

    if use_ie == false && browser =~ /INTERNET EXPLORER/
      use_ie = true
    end

    all_times_use_chrome = false unless browser =~ /CHROME/

    session_dates << session['date'].strip
    user_sessions_cn += 1
  end

  # Собираем количество сессий по пользователям
  report[user_key]['sessionsCount'] = user_sessions_cn

  # Собираем количество времени по пользователям
  report[user_key]['totalTime'] = "#{session_times.sum.to_s} min."

  # Выбираем самую длинную сессию пользователя
  report[user_key]['longestSession'] = "#{session_times.max.to_s} min."

  # Браузеры пользователя через запятую
  report[user_key]['browsers'] = session_browsers.sort.join(', ')

  # Хоть раз использовал IE?
  report[user_key]['usedIE'] = use_ie

  # Всегда использовал только Chrome?
  report[user_key]['alwaysUsedChrome'] = all_times_use_chrome

  # Даты сессий через запятую в обратном порядке в формате iso8601
  report[user_key]['dates'] = session_dates.sort.reverse

  report
end

# Статистика по пользователю
def report_user(user_attributes)
  sessions = user_attributes.delete('sessions')
  user_object = User.new(attributes: user_attributes, sessions: sessions)

  collect_stats_from_users(user_object)
end

# Отчёт в json
#   - Сколько всего юзеров +
#   - Сколько всего уникальных браузеров +
#   - Сколько всего сессий +
#   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
#
#   - По каждому пользовател
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +
def work(file_path = 'data_large.txt')
  file = File.open(file_path)
  file_result = File.open('result.json', 'w')

  # Используем users в качестве Hash, дабы чтобы в нем можно было в нем хранить не только аттрибуты, но и также сессии
  users = {}

  # Во время перебора строк сразу же собираем браузеры
  unique_browsers = Set[]

  # А также подсчитываем кол-во сессий
  sessions_count = 0
  users_count = 0
  file_result.write(%Q[{"usersStats": {])

  old_user_id = nil
  file.each do |line|
    if line.start_with?('user')
      if old_user_id
        # Записываем статистику по пользователю
        file_result.write("#{Oj.dump(report_user(users[old_user_id]))[1...-1]},")

        # Убиваем ненужного юзера
        users.delete(old_user_id)
      end

      user_attributes = parse_user(line)
      users[user_attributes['id']] = user_attributes
      old_user_id = user_attributes['id']

      users_count += 1
    else
      session_attributes = parse_session(line)
      # нужному юзеру присваиваем сессии

      users[session_attributes['user_id']]['sessions'] ||= []
      users[session_attributes['user_id']]['sessions'] << session_attributes

      # собираем все браузеры
      unique_browsers << session_attributes['browser'].upcase!

      # иттерируем сессии
      sessions_count += 1
    end

    # У последней строки собираем всю статутистику по пользователю
    if file.eof?
      file_result.write(Oj.dump(report_user(users[old_user_id]))[1...-1])
      users.delete(old_user_id)
    end
  end

  file_result.write("},")

  # Мержим, для того, чтобы сохранить изначальный порядок хеша (json)
  report = Oj.dump({
   'totalUsers' => users_count,
   'uniqueBrowsersCount' => unique_browsers.count,
   'totalSessions' => sessions_count,
   'allBrowsers' => unique_browsers.sort.join(',')
  })

  file_result.write(report[1..-1])
  file_result.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
