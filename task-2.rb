# Deoptimized version of homework task

require 'json'
require 'pry'
require 'date'

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

SESSION_REGEXP = /session,\d+,\d+,(?<browser>[\w ]+ \d+),(?<time>\d+),(?<date>.*)/.freeze

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:)
    @attributes = attributes
    @sessions_count = 0
    @total_time = 0
    @longest_session = -1
    @browsers = []
    @used_ie = false
    @always_used_chrome = true
    @dates = []
  end

  def push_session(session)
    @sessions_count += 1

    session_time = session['time'].to_i
    @total_time += session_time
    @longest_session = session_time if session_time > @longest_session

    browser = session['browser'].upcase
    @browsers.push(browser)

    @used_ie ||= !(browser =~ /INTERNET EXPLORER/).nil? || false
    @always_used_chrome &&= !(browser =~ /CHROME/).nil? || false

    @dates.push(session['date'])
  end

  def flush(file, last: false)
    file.write("\"#{attributes['first_name']}" + ' ' + "#{attributes['last_name']}\":")
    file.write(
      {
        'sessionsCount' => @sessions_count,
        'totalTime' => "#{@total_time} min.",
        'longestSession' => "#{@longest_session} min.",
        'browsers' => @browsers.sort.join(', '),
        'usedIE' => @used_ie,
        'alwaysUsedChrome' => @always_used_chrome,
        'dates' => @dates.sort!.reverse!
      }.to_json
    )
    file.write(',') unless last
  end
end

def parse_user(user)
  fields = user.split(',')
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(session)
  fields = session.split(',')
  parsed_result = {
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def write_users_prefix(file)
  file.write('{"usersStats":{')
end

def write_users_suffix(file)
  file.write('},')
end

def process_input_file(input_file, result_file)
  current_user = nil
  users_count = 0
  sessions_count = 0
  browsers = []
  while true
    line = input_file.readline.strip!
    if line.start_with?('user')
      users_count += 1
      current_user&.flush(result_file)
      current_user = User.new(attributes: parse_user(line))
    elsif line.start_with?('session')
      sessions_count += 1
      parsed_session = parse_session(line)
      upcase_browser = parsed_session['browser'].upcase
      browsers.push(upcase_browser) unless browsers.include?(upcase_browser)
      current_user.push_session(parsed_session)
    end
  end
  [users_count, sessions_count, browsers]
rescue EOFError
  input_file.close
  current_user.flush(result_file, last: true)
  [users_count, sessions_count, browsers]
end

def work(file_name)
  input_file = File.open(file_name)
  result_file = File.open('result.json', 'w')

  write_users_prefix(result_file)
  users_count, sessions_count, browsers = process_input_file(input_file, result_file)
  write_users_suffix(result_file)

  browsers.sort!
  result_file.write("\"uniqueBrowsersCount\":#{browsers.size},")
  result_file.write("\"allBrowsers\":\"#{browsers.join(',')}\",")
  result_file.write("\"totalSessions\":#{sessions_count},")
  result_file.write("\"totalUsers\":#{users_count}}")
  result_file.close
end
