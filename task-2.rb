# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
#require 'pry'
require 'date'
require 'json'


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
    'browser' => fields[3].upcase,
    'time' => fields[4],
    'date' => fields[5],
  }
end


def add_stasts sessions
  { 
    'sessionsCount' => sessions.count, 
  # Собираем количество времени по пользователям
    'totalTime' => sessions.map {|s| s['time']}.map {|t| t.to_i}.sum.to_s + ' min.',

  # Выбираем самую длинную сессию пользователя
    'longestSession' => sessions.map {|s| s['time']}.map {|t| t.to_i}.max.to_s + ' min.',
  # Браузеры пользователя через запятую
    'browsers' => sessions.map {|s| s['browser']}.map {|b| b.upcase}.sort.join(', '),
  # Хоть раз использовал IE?
    'usedIE' => sessions.map{|s| s['browser']}.any? { |b| b.upcase =~ /INTERNET EXPLORER/ },
    'alwaysUsedChrome' => sessions.map{|s| s['browser']}.all? { |b| b.upcase =~ /CHROME/ },
  # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => sessions.map{|s| s['date']}.sort.reverse
  }

end 

def work filename = 'data.txt', gc_disable=false
  GC.disable if gc_disable
  puts "start work..."
  users = []
  sessions = []
  all_browsers = [] 
  totalSessions = 0
  totalUsers = 0
  report = {}
  report['usersStats'] = {}
  user = nil
  File.write('result.json', '{"usersStats":{')

  File.open(filename, :encoding => "ASCII").each_line do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      totalUsers += 1
      unless sessions.empty?

        user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
        add_stats = add_stasts(sessions)

        File.write('result.json', "\"#{user_key}\":", mode: 'a')
        File.write('result.json', "#{add_stats.to_json}\n", mode: 'a')
        File.write('result.json', ",", mode: 'a')
      end
      sessions = []
      user = parse_user(line)
    end

    if cols[0] == 'session'
      totalSessions += 1
      ses = parse_session(line)
      sessions << ses
      all_browsers << ses['browser']
      
    end
  end

  user_key = "#{user['first_name']}" + ' ' + "#{user['last_name']}"
  add_stats = add_stasts(sessions)

  File.write('result.json', "\"#{user_key}\":", mode: 'a')
  File.write('result.json', "#{add_stats.to_json}\n", mode: 'a')
  File.write('result.json', "},\n\n\n", mode: 'a')

  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

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

  #report[:totalUsers] = totalUsers
  File.write('result.json', "\"totalUsers\":#{totalUsers},\n", mode: 'a')
  # Подсчёт количества уникальных браузеров
  #report['uniqueBrowsersCount'] = all_browsers.uniq.count
  File.write('result.json', "\"uniqueBrowsersCount\":#{all_browsers.uniq.count},\n", mode: 'a')

  #report['totalSessions'] = totalSessions
  File.write('result.json', "\"totalSessions\":#{totalSessions},\n", mode: 'a')
  #report['allBrowsers'] =
  allBrowsers = all_browsers
      .sort
      .uniq
      .join(',')
  File.write('result.json', "\"allBrowsers\":#{allBrowsers.to_json}\n", mode: 'a')    
  File.write('result.json', "}", mode: 'a')
  puts ObjectSpace.count_objects
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
#work('data/data50000.txt', true)