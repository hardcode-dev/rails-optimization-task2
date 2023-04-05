# frozen_string_literal: true

require 'json'
require 'byebug'
require 'oj'

class User
  attr_reader :name, :sessions

  def initialize(name:, sessions:)
    @name = name
    @sessions = sessions
  end
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

def work(file: nil, disable_gc: false)
  file ||= ENV['DATA_FILE'] || 'data.txt'

  puts "Start work for file: #{file}"
  start_time = Time.now.utc

  GC.disable if disable_gc

  # prepare vars
  @sessions = []
  @uniq_browsers = Set.new
  @total_users = 0
  @total_sessions = 0
  @current_user = nil
  @index = 0
  @user_name = nil

  result_file = File.open('data/result.json', 'w')
  @result = Oj::StreamWriter.new(result_file)

  @result.push_object
  @result.push_key('usersStats')
  @result.push_object

  IO.foreach(file, chomp: true) do |line|
    if line[0] == 'u'
      process_user(line)
    else
      process_session(line)
    end
  end

  process_last_user
  process_other_keys
  result_file.close

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  puts "Finish work! Time: #{Time.now.utc - start_time}"
end

def process_user(line)
  if @current_user != nil
    @result.push_value(collect_data_for_user(@current_user), @current_user.name)
    @current_user = nil
  end

  fetch_user_name(line)
  @current_user = User.new(name: @user_name, sessions: [])
  @total_users += 1
end

def process_last_user
  @result.push_value(collect_data_for_user(@current_user), @current_user.name)
  @result.pop
end

def process_session(line)
  session = parse_session(line)
  @current_user.sessions << session
  @uniq_browsers << session['browser'].upcase

  @total_sessions += 1
end

def process_other_keys
  @result.push_value(@total_users, 'totalUsers')
  @result.push_value(@total_sessions, 'totalSessions')
  @result.push_value(@uniq_browsers.count, 'uniqueBrowsersCount')
  @result.push_value(@uniq_browsers.sort.join(','), 'allBrowsers')
  @result.pop
end

# упоролся в оптимизацию, такой код тяжело читать
def fetch_user_name(line)
  @index = 0
  @user_name = nil

  line.split(',') do |str|
    @user_name = str if @index == 2
    break @user_name << " #{str}" if @index == 3
    @index += 1
  end
end

def parse_session(line)
  cols = line.split(',')

  {
    'browser' => cols[3],
    'time' => cols[4],
    'date' => cols[5]
  }
end

def collect_data_for_user(user)
  data = Hash.new

  data['sessionsCount'] = collect_sessions_count(user)

  time = user.sessions.map {|s| s['time']}
  browsers = user.sessions.map {|s| s['browser']}.map! {|b| b.upcase}

  data['totalTime'] = collect_total_time(time)
  data['longestSession'] = collect_longest_session(time)

  data['browsers'] = collect_browsers(browsers)
  data['usedIE'] = collect_used_ie(browsers)
  data['alwaysUsedChrome'] = collect_always_used_chrome(browsers)

  data['dates'] = collect_dates(user)

  data
end

def collect_sessions_count(user)
  user.sessions.count
end

def collect_total_time(time)
  "#{time.map! {|t| t.to_i}.sum} min."
end

def collect_longest_session(time)
  "#{time.map! {|t| t.to_i}.max} min."
end

def collect_browsers(browsers)
  browsers.sort.join(', ')
end

def collect_used_ie(browsers)
  browsers.any? { |b| b.start_with? 'INTERNET EXPLORER' }
end

def collect_always_used_chrome(browsers)
  browsers.all? { |b| b.start_with? 'CHROME' }
end

def collect_dates(user)
  user.sessions.map! {|s| s['date']}.sort.reverse
end
