# Deoptimized version of homework task
# frozen_string_literal: true

require 'json'
require 'date'
require 'json'
require 'set'

def add_stats user_sessions_count, user_browser, user_time, user_date
  browsers_map = user_browser
  time_map = user_time
  { 
    'sessionsCount' => user_sessions_count, 
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

class FileWriter
  def initialize file
    @file = file
  end

  def write data
    @file.write(data)
  end

  def finish
    @file.close()
  end
end


REGEXP_USER = Regexp.new('(\w+),(\d+),(\w+),(\w+),(\d+)') 
REGEXP_SESSION = Regexp.new('(\w+),(\d+),(\d+),(.+),(\d+),([\w|-]+)')

def work filename = 'data.txt', gc_disable=false
  filename = ENV['DATA_FILE'] || filename

  GC.disable if gc_disable
  puts "start work..."
  all_browsers = Set.new
  totalSessions = 0
  totalUsers = 0
  user = nil

  user_browser = []
  user_time = []
  user_date = []
  user_sessions_count = 0

  writer = FileWriter.new(File.open('result.json', mode: 'a'))

  writer.write('{"usersStats":{')
  
  File.open(filename).each_line do |line|
    
    if line.start_with?("user")
      totalUsers += 1
      if user_sessions_count > 0
        add_stats = add_stats(user_sessions_count, user_browser, user_time, user_date)
        writer.write("\"#{user[3]} #{user[4]}\":#{add_stats.to_json},")
      end
      user_sessions_count = 0
      user = REGEXP_USER.match(line)

      user_browser = []
      user_time = []
      user_date = []
      
    end

    if line.start_with?("session")
      cols = REGEXP_SESSION.match(line)
      totalSessions += 1
      user_sessions_count += 1
      browser = cols[4].upcase!
      all_browsers << browser
      user_browser << browser
      user_time << cols[5].to_i
      user_date << cols[6]
    end
  end

  add_stats = add_stats(user_sessions_count, user_browser, user_time, user_date)
  writer.write("\"#{user[3]} #{user[4]}\":#{add_stats.to_json}},")


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

  writer.write("\"totalUsers\":#{totalUsers},\n")
  writer.write("\"uniqueBrowsersCount\":#{all_browsers.count},\n")
  writer.write("\"totalSessions\":#{totalSessions},\n")
  
  # Тут пробовал вариант с SortedSet – больше объектов создается :(
  #allBrowsers = all_browsers.inject("".dup){ | r,i |  r << i << "," }.chop
  allBrowsers = all_browsers
    .sort
    .join(',')  
  writer.write("\"allBrowsers\":#{allBrowsers.to_json}\n")    
  writer.write("}")

  writer.finish()
  puts ObjectSpace.count_objects
  puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end
gc_disable = false 
gc_disable = true unless ENV['GC']
work('data/data50000.txt', gc_disable) if ENV['DATA']