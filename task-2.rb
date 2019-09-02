# frozen_string_literal: true
# Deoptimized version of homework task
# require 'json'
# require 'pry'
require 'oj'

# GC.disable

COMMA = ','
EMPTY = ''
SESSION = 'session'
USER = 'user'

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(cols)
  {
      id: cols[1],
      first_name: cols[2],
      last_name: cols[3],
      age: cols[4]
  }
end

def parse_session(cols)
  {
      user_id: cols[1],
      session_id: cols[2],
      browser: cols[3],
      browser_upcase: cols[3].upcase,
      time: cols[4],
      time_to_i: cols[4].to_i,
      date: cols[5].chomp
  }
end

def print_to_temp_file(tempfile, user_key, report_users_stats_user_key, last_line)
  # Собираем количество времени по пользователям
  report_users_stats_user_key['totalTime'] = report_users_stats_user_key['totalTime'].sum.to_s + ' min.'
  # Выбираем самую длинную сессию пользователя
  report_users_stats_user_key['longestSession'] = report_users_stats_user_key['longestSession'].max.to_s + ' min.'
  # Браузеры пользователя через запятую
  report_users_stats_user_key['browsers'] = report_users_stats_user_key['browsers'].sort.join(', ')
  # Даты сессий через запятую в обратном порядке в формате iso8601
  report_users_stats_user_key['dates'] = report_users_stats_user_key['dates'].sort!.reverse!

  if last_line
    tempfile.write "\"#{user_key}\":#{Oj.dump(report_users_stats_user_key, mode: :compat)}"
  else
    tempfile.write "\"#{user_key}\":#{Oj.dump(report_users_stats_user_key, mode: :compat)},\n"
  end
end

def parse_file(file)
  puts file
  report = {}
  report['totalUsers'] = 0
  report['uniqueBrowsersCount'] = {}
  report['totalSessions'] = 0
  report['allBrowsers'] = {}

  tempfile = File.open("tempfile","w")
  report_users_stats_user_key = {}
  user_key = nil

  File.foreach(file) do |line|
    cols = line.split(COMMA)

    if cols[0] == USER
      user = parse_user(cols)
      report['totalUsers'] += 1

      # Если User, значит прошлый  User обсчитан. Проверяем что прошлый юзер есть (этот не первый)
      if report_users_stats_user_key.any?
        # Если прошлый юзер есть, подбиваем по нему статистику и сбрасываем на диск
        print_to_temp_file(tempfile, user_key, report_users_stats_user_key, false)
      end

      # Обуляем user key и hash для обсчета следующего пользователя
      user_key = "#{user[:first_name]} #{user[:last_name]}"
      report_users_stats_user_key = {}

      # Подготавливаем шаблон отчета
      report_users_stats_user_key['sessionsCount'] = 0
      report_users_stats_user_key['totalTime'] = []
      report_users_stats_user_key['longestSession'] = []
      report_users_stats_user_key['browsers'] = []
      report_users_stats_user_key['usedIE'] = false
      report_users_stats_user_key['alwaysUsedChrome'] = true
      report_users_stats_user_key['dates'] = []
    end

    if cols[0] == SESSION
      session = parse_session(cols)

      report['totalSessions'] += 1
      report['uniqueBrowsersCount'][session[:browser]] = true
      report['allBrowsers'][session[:browser_upcase]] = true

      report_users_stats_user_key['sessionsCount'] += 1
      report_users_stats_user_key['totalTime'] << session[:time_to_i]
      report_users_stats_user_key['longestSession'] << session[:time_to_i]
      report_users_stats_user_key['browsers'] << session[:browser_upcase]
      unless report_users_stats_user_key['usedIE']
        report_users_stats_user_key['usedIE'] = (session[:browser_upcase] =~ /INTERNET EXPLORER/) ? true : false
      end
      if report_users_stats_user_key['alwaysUsedChrome']
        report_users_stats_user_key['alwaysUsedChrome'] = (session[:browser_upcase] =~ /CHROME/) ? true : false
      end
      report_users_stats_user_key['dates'] << session[:date]

    end
  end

  # Сохраняем последнего пользователя
  print_to_temp_file(tempfile, user_key, report_users_stats_user_key, true)
  tempfile.close

  report['uniqueBrowsersCount'] = report['uniqueBrowsersCount'].count
  report['allBrowsers'] = report['allBrowsers'].keys.sort.join(',')
  report
end

def work(file = 'data.txt')
  report = parse_file(file)
  result_file_name = file == 'data.txt' ? 'result.json' : "#{file}.json"

  File.open(result_file_name,"w") do |f|
    st = Oj.dump(report, mode: :compat)
    f.write st.delete_suffix('}')
    f.write ",\"usersStats\":{"
    File.open("tempfile").each do |line|
      f.write line.chomp
    end
    f.write "}}"
    f.write "\n"
  end
  File.delete('tempfile')
end



if ARGV.any?
  puts "process #{ARGV.first} ..."
  work(ARGV.first)
  puts "rss after #{print_memory_usage}"
else
  puts 'no file to process'
end
