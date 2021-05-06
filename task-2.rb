# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
#require 'pry'
require 'date'
require 'json'


def parse_user(fields)
  parsed_result = {
    'id' => fields[1],
    'first_name' => fields[2],
    'last_name' => fields[3],
    'age' => fields[4],
  }
end

def parse_session(fields)
  parsed_result = {
    'browser' => fields[4].upcase!,
    'time' => fields[5],
    'date' => fields[6],
  }
end

def add_stasts sessions
  browsers_map = sessions.map {|s| s['browser']}
  time_map = sessions.map {|s| s['time'].to_i}
  { 
    'sessionsCount' => sessions.count, 
  # Собираем количество времени по пользователям
    'totalTime' => time_map.sum.to_s << ' min.',
  # Выбираем самую длинную сессию пользователя
    'longestSession' => time_map.max.to_s << ' min.',
  # Хоть раз использовал IE?
    'usedIE' => browsers_map.any? { |b| b.start_with?("INTERNET EXPLORER") },
    'alwaysUsedChrome' => browsers_map.all? { |b| b.start_with?("CHROME") },    
  # Браузеры пользователя через запятую
    'browsers' => browsers_map.map! {|b| b}.sort!.join(', '),
    # Даты сессий через запятую в обратном порядке в формате iso8601
    'dates' => sessions.map{|s| s['date']}.sort!.reverse!
  }

end 

REGEXP_USER = Regexp.new('(\w+),(\d+),(\w+),(\w+),(\d+)') 
REGEXP_SESSION = Regexp.new('(\w+),(\d+),(\d+),(.+),(\d+),([\w|-]+)')

def work filename = 'data.txt', gc_disable=false
  GC.disable if gc_disable
  puts "start work..."
  users = []
  sessions = []
  all_browsers = [] 
  totalSessions = 0
  totalUsers = 0
  report = {}
  user = nil
  File.write('result.json', '{"usersStats":{')

  File.open(filename).each_line do |line|
    
    if line.start_with?("user")
      totalUsers += 1
      unless sessions.empty?

        user_key = "#{user[3]}" + ' ' + "#{user[4]}"
        add_stats = add_stasts(sessions)

        File.write('result.json', "\"#{user_key}\":", mode: 'a')
        File.write('result.json', "#{add_stats.to_json}\n", mode: 'a')
        File.write('result.json', ",", mode: 'a')
      end
      sessions = []
      user = REGEXP_USER.match(line)
    end

    if line.start_with?("session")
      cols = REGEXP_SESSION.match(line)
      totalSessions += 1
      ses = parse_session(cols)
      sessions << ses
      all_browsers << ses['browser']
      
    end
  end

  user_key = "#{user[3]}" + ' ' + "#{user[4]}"
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
gc_disable = false 
gc_disable = true unless ENV['GC']
work('data/data50000.txt', gc_disable) if ENV['DATA']