# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'date'
require 'json'

def add_stats sessions, user_browser, user_time, user_date
  browsers_map = user_browser
  time_map = user_time
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
    'dates' => user_date.sort!.reverse!
  }

end 

REGEXP_USER = Regexp.new('(\w+),(\d+),(\w+),(\w+),(\d+)') 
REGEXP_SESSION = Regexp.new('(\w+),(\d+),(\d+),(.+),(\d+),([\w|-]+)')

def work filename = 'data.txt', gc_disable=false
  filename = ENV['DATA_FILE'] || filename

  GC.disable if gc_disable
  puts "start work..."
  users = []
  sessions = []
  all_browsers = [] 
  totalSessions = 0
  totalUsers = 0
  report = {}
  user = nil

  user_browser = []
  user_time = []
  user_date = []

  File.write('result.json', '{"usersStats":{')

  File.open(filename).each_line do |line|
    
    if line.start_with?("user")
      totalUsers += 1
      unless sessions.empty?

        #user_key = "#{user[3]}" + ' ' + "#{user[4]}"
        add_stats = add_stats(sessions, user_browser, user_time, user_date)

        #File.write('result.json', "\"#{user_key}\":#{add_stats.to_json},", mode: 'a')
        File.write('result.json', "\"#{user[3]} #{user[4]}\":#{add_stats.to_json},", mode: 'a')
      end
      sessions = []
      user = REGEXP_USER.match(line)

      user_browser = []
      user_time = []
      user_date = []
      
    end

    if line.start_with?("session")
      cols = REGEXP_SESSION.match(line)
      totalSessions += 1
      sessions << cols
      browser = cols[4].upcase!
      
      #use set plz
      all_browsers << browser unless all_browsers.include?(browser)

      user_browser << browser
      user_time << cols[5].to_i
      user_date << cols[6]
    end
  end

  add_stats = add_stats(sessions, user_browser, user_time, user_date)
  File.write('result.json', "\"#{user[3]} #{user[4]}\":#{add_stats.to_json}},", mode: 'a')


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

  File.write('result.json', "\"totalUsers\":#{totalUsers},\n", mode: 'a')
  File.write('result.json', "\"uniqueBrowsersCount\":#{all_browsers.count},\n", mode: 'a')
  File.write('result.json', "\"totalSessions\":#{totalSessions},\n", mode: 'a')
  allBrowsers = all_browsers
      .sort
      .join(',')
  File.write('result.json', "\"allBrowsers\":#{allBrowsers.to_json}\n", mode: 'a')    
  File.write('result.json', "}", mode: 'a')
  puts ObjectSpace.count_objects
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
gc_disable = false 
gc_disable = true unless ENV['GC']
work('data/data50000.txt', gc_disable) if ENV['DATA']