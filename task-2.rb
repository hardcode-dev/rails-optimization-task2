# frozen_string_literal: true

require 'json'
require 'byebug'
require 'oj'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end

  def name
    "#{attributes['first_name']} #{attributes['last_name']}"
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

  GC.disable if disable_gc

  @sessions = []
  @uniq_browsers = Set.new
  @total_users = 0
  @total_sessions = 0

  result_file = File.open('data/result.json', 'w')
  @result = Oj::StreamWriter.new(result_file)

  @result.push_object
  @result.push_key('usersStats')
  @result.push_object

  current_user = nil

  IO.foreach(file, chomp: true) do |line|
    cols = line.split(',')

    if cols[0] == 'user'
      if current_user != nil
        data_for_user = collect_data_for_user(current_user)
        @result.push_value(data_for_user, current_user.name)
        current_user = nil
      end

      attributes = parse_user(cols)
      current_user = User.new(attributes: attributes, sessions: [])
      @total_users += 1
    else
      session = parse_session(cols)
      current_user.sessions << session
      @uniq_browsers << session['browser'].upcase

      @total_sessions += 1
    end
  end

  @result.push_value(collect_data_for_user(current_user), current_user.name) # solution for last user
  @result.pop

  # write other keys
  @result.push_value(@total_users, 'totalUsers')
  @result.push_value(@total_sessions, 'totalSessions')
  @result.push_value(@uniq_browsers.count, 'uniqueBrowsersCount')
  @result.push_value(@uniq_browsers.sort.join(','), 'allBrowsers')
  @result.pop

  result_file.close

  puts ObjectSpace.each_object(String).count # => 21197866

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(cols)
  {
    'id' => cols[1],
    'first_name' => cols[2],
    'last_name' => cols[3],
    'age' => cols[4],
  }
end

def parse_session(cols)
  {
    'user_id' => cols[1],
    'session_id' => cols[2],
    'browser' => cols[3],
    'time' => cols[4],
    'date' => cols[5],
  }
end

def collect_data_for_user(user)
  {
    'sessionsCount' => collect_sessions_count(user),
    'totalTime' => collect_total_time(user),
    'longestSession' => collect_longest_session(user),
    'browsers' => collect_browsers(user),
    'usedIE' => collect_used_ie(user),
    'alwaysUsedChrome' => collect_always_used_chrome(user),
    'dates' => collect_dates(user)
  }
end

def collect_sessions_count(user)
  user.sessions.count
end

def collect_total_time(user)
  user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.'
end

def collect_longest_session(user)
  user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.'
end

def collect_browsers(user)
  user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ')
end

def collect_used_ie(user)
  user.sessions.map{|s| s['browser']}.any? { |b| b.upcase.start_with? 'INTERNET EXPLORER' }
end

def collect_always_used_chrome(user)
  user.sessions.map{|s| s['browser']}.all? { |b| b.start_with? 'CHROME' }
end

def collect_dates(user)
  user.sessions.map{|s| s['date']}.sort.reverse
end
