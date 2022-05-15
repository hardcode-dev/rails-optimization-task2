require 'json'
# require 'pry'
require 'date'
require 'set'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
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
    'user_id' => fields[1],
    'session_id' => fields[2],
    'browser' => fields[3],
    'time' => fields[4],
    'date' => fields[5],
  }
end

def write_user_stats(user_attrs, user_sessions, last = false)
  user = User.new(attributes: user_attrs, sessions: user_sessions)

  report = {}

  # Собираем количество сессий по пользователям
  report['sessionsCount'] = user.sessions.count

  # Собираем количество времени по пользователям
  report['totalTime'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'

  # Выбираем самую длинную сессию пользователя
  report['longestSession'] = user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'

  # Браузеры пользователя через запятую
  report['browsers'] = user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')

  # Хоть раз использовал IE?
  report['usedIE'] = user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }

  # Всегда использовал только Chrome?
  report['alwaysUsedChrome'] = user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ }

  # Даты сессий через запятую в обратном порядке в формате iso8601
  report['dates'] = user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }

  user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
  to_write = "\"#{user_key}\":#{report.to_json}"
  to_write << ',' unless last

  File.open('result.json', 'a') do |f|
    f.puts to_write
  end
end

def work(filename = nil)
  filename ||= ENV['DATA_FILE']

  total_users = 0
  total_sessions = 0
  unique_browsers = Set.new

  user = nil
  user_sessions = []
  line_type = nil
  prev_line_type = nil

  File.write('result.json', '{"usersStats":{')

  File.foreach(filename).with_index do |line, i|
    cols = line.split(',')
    line_type = cols[0]

    if line_type == 'user' && prev_line_type != nil
      write_user_stats(user, user_sessions)
      user_sessions = []
    end
    prev_line_type = line_type

    if line_type == 'session'
      session = parse_session(line)
      user_sessions << session
      total_sessions += 1

      unique_browsers << session['browser']
    elsif line_type == 'user'
      user = parse_user(line)
      total_users += 1
    end
  end

  # Stats for the last user
  write_user_stats(user, user_sessions, _last = true)

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

  total_report = {
    totalUsers: total_users,
    uniqueBrowsersCount: unique_browsers.count,
    totalSessions: total_sessions,
    allBrowsers: unique_browsers.to_a.map(&:upcase).sort.join(',')
  }

  File.open('result.json', 'a') do |f|
    f.puts "},#{total_report.to_json[1..-1]}"
  end

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts "Done. Processed file #{filename}."
end
