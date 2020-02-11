# Deoptimized version of homework task

require 'json'
require 'pry'
# require 'date'

# class User
#   attr_reader :attributes, :sessions

#   def initialize(attributes:, sessions:)
#     @attributes = attributes
#     @sessions = sessions
#   end
# end

# def parse_user(user)
#   fields = user.split(',')
#   parsed_result = {
#     'id' => fields[1],
#     'first_name' => fields[2],
#     'last_name' => fields[3],
#     'age' => fields[4],
#   }
# end

# def parse_session(session)
#   fields = session.split(',')
#   parsed_result = {
#     'user_id' => fields[1],
#     'session_id' => fields[2],
#     'browser' => fields[3],
#     'time' => fields[4],
#     'date' => fields[5],
#   }
# end

# def collect_stats_from_users(report, users_objects, &block)
#   users_objects.each do |user|
#     user_key = "#{user.attributes['first_name']}" + ' ' + "#{user.attributes['last_name']}"
#     report['usersStats'][user_key] ||= {}
#     report['usersStats'][user_key] = report['usersStats'][user_key].merge(block.call(user))
#   end
# end

def work(filename='data.txt', disable_gc=false)
  GC.disable if disable_gc

  @total_users = 0
  @total_sessions = 0

  @all_browsers = []
  @unique_browsers_count = 0

  File.write('result.json', '{"usersStats":{')

  File.foreach(filename) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      write_user_data unless @total_users == 0
      parse_user(line)
    end
    if cols[0] == 'session'
      parse_session(line)
    end
  end
  write_user_data(true)
  add_stats
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(user)
  fields = user.split(',')
  @user_sessions_count = 0
  @user_total_time = 0
  @user_max_time = 0
  @user_browsers = []
  @session_dates = []
  @total_users += 1

  @full_name = "#{fields[2]} #{fields[3]}"
end

def parse_session(session)
  fields = session.split(',')
  @user_sessions_count += 1
  @total_sessions += 1
  session_time = fields[4].to_i
  @user_total_time += session_time
  @user_max_time = [@user_max_time, session_time].max
  current_browser = fields[3].upcase
  @user_browsers << current_browser
  @all_browsers << current_browser unless @all_browsers.include?(current_browser)
  @session_dates << fields[5].gsub(/\n/,"")
  @used_ie = @user_browsers.map{|s| s.match?(/INTERNET EXPLORER/) }.any?
  @always_chrome = @used_ie ? false : @user_browsers.all?{|s| s.match?(/CHROME/)}
end

def write_user_data(last=false)
  user_stats = {}
  user_stats[@full_name] = {}
  user_stats[@full_name]["sessionsCount"] = @user_sessions_count
  user_stats[@full_name]["totalTime"] = "#{@user_total_time} min."
  user_stats[@full_name]["longestSession"] = "#{@user_max_time} min."
  user_stats[@full_name]["browsers"] = @user_browsers.sort.join(', ')
  user_stats[@full_name]["usedIE"] = @used_ie
  user_stats[@full_name]["alwaysUsedChrome"] = @always_chrome
  user_stats[@full_name]["dates"] = @session_dates.sort.reverse
  closing_char = last ? "}," : ","
  File.write('result.json', "\"#{@full_name}\":#{user_stats[@full_name].to_json}#{closing_char}", mode: 'a')
end

def add_stats
  stats = {}
  stats["totalUsers"] = @total_users
  stats["totalSessions"] = @total_sessions
  stats["allBrowsers"] = @all_browsers.sort.join(',')
  stats["uniqueBrowsersCount"] = @all_browsers.count
  File.write('result.json', "#{stats.to_json.gsub('}', '').gsub('{', '')}}", mode: 'a')
end

  # report = {}

  # report[:totalUsers] = users.count

  # Подсчёт количества уникальных браузеров
  # uniqueBrowsers = []
  # sessions.each do |session|
  #   browser = session['browser']
  #   uniqueBrowsers += [browser] if uniqueBrowsers.all? { |b| b != browser }
  # end

  # report['uniqueBrowsersCount'] = uniqueBrowsers.count

  # report['totalSessions'] = sessions.count

  # report['allBrowsers'] =
  #   sessions
  #     .map { |s| s['browser'] }
  #     .map { |b| b.upcase }
  #     .sort
  #     .uniq
  #     .join(',')

  # Статистика по пользователям
  # users_objects = []

  # users.each do |user|
  #   attributes = user
  #   user_sessions = sessions.select { |session| session['user_id'] == user['id'] }
  #   user_object = User.new(attributes: attributes, sessions: user_sessions)
  #   users_objects = users_objects + [user_object]
  # end

  # report['usersStats'] = {}

  # Собираем количество сессий по пользователям
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'sessionsCount' => user.sessions.count }
  # end

  # Собираем количество времени по пользователям
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'totalTime' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.' }
  # end

  # # Выбираем самую длинную сессию пользователя
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'longestSession' => user.sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.' }
  # end

  # # Браузеры пользователя через запятую
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'browsers' => user.sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', ') }
  # end

  # # Хоть раз использовал IE?
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'usedIE' => user.sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ } }
  # end

  # # Всегда использовал только Chrome?
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'alwaysUsedChrome' => user.sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ } }
  # end

  # # Даты сессий через запятую в обратном порядке в формате iso8601
  # collect_stats_from_users(report, users_objects) do |user|
  #   { 'dates' => user.sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 } }
  # end

  # File.write('result.json', "#{report.to_json}\n")
