# frozen_string_literal: true
# Deoptimized version of homework task
require 'json'
require 'pry'
require 'oj'

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

def parse_user(fields)
  {
      id: fields[1],
      first_name: fields[2],
      last_name: fields[3],
      age: fields[4],
  }
end

def parse_session(fields)
  {
      user_id: fields[1],
      session_id: fields[2],
      browser: fields[3],
      browser_upcase: fields[3].upcase,
      time: fields[4],
      time_to_i: fields[4].to_i,
      date: fields[5].chomp!
  }
end

def parse_file(file)
  report = {}
  users = {}
  report['totalUsers'] = 0
  report['uniqueBrowsersCount'] = {}
  report['totalSessions'] = 0
  report['allBrowsers'] = {}
  report['usersStats'] = {}

  File.foreach(file) do |line|
    cols = line.split(',')
    if cols[0] == 'user'
      user = parse_user(cols)
      report['totalUsers'] += 1
      users[user[:id]] = user
      user_key = "#{user[:first_name]} #{user[:last_name]}"
      report['usersStats'][user_key] = {}

      report['usersStats'][user_key]['sessionsCount'] = 0
      report['usersStats'][user_key]['totalTime'] = []
      report['usersStats'][user_key]['longestSession'] = []
      report['usersStats'][user_key]['browsers'] = []
      report['usersStats'][user_key]['usedIE'] = false
      report['usersStats'][user_key]['alwaysUsedChrome'] = true
      report['usersStats'][user_key]['dates'] = []
    end

    if cols[0] == 'session'
      session = parse_session(cols)

      report['totalSessions'] += 1
      report['uniqueBrowsersCount'][session[:browser]] = true
      report['allBrowsers'][session[:browser_upcase]] = true

      user_key = "#{users[session[:user_id]][:first_name]} #{users[session[:user_id]][:last_name]}"
      report['usersStats'][user_key]['sessionsCount'] += 1
      report['usersStats'][user_key]['totalTime'] << session[:time_to_i]
      report['usersStats'][user_key]['longestSession'] << session[:time_to_i]
      report['usersStats'][user_key]['browsers'] << session[:browser_upcase]
      unless report['usersStats'][user_key]['usedIE']
        report['usersStats'][user_key]['usedIE'] = (session[:browser_upcase] =~ /INTERNET EXPLORER/) ? true : false
      end
      if report['usersStats'][user_key]['alwaysUsedChrome']
        report['usersStats'][user_key]['alwaysUsedChrome'] = (session[:browser_upcase] =~ /CHROME/) ? true : false
      end
      report['usersStats'][user_key]['dates'] << session[:date]

    end
  end

  report['uniqueBrowsersCount'] = report['uniqueBrowsersCount'].count
  report['allBrowsers'] = report['allBrowsers'].keys.sort.join(',')

  report['usersStats'].keys.each do |user_key|
    # Собираем количество времени по пользователям
    report['usersStats'][user_key]['totalTime'] = report['usersStats'][user_key]['totalTime'].sum.to_s + ' min.'
    # Выбираем самую длинную сессию пользователя
    report['usersStats'][user_key]['longestSession'] = report['usersStats'][user_key]['longestSession'].max.to_s + ' min.'
    # Браузеры пользователя через запятую
    report['usersStats'][user_key]['browsers'] = report['usersStats'][user_key]['browsers'].sort.join(', ')
    # Даты сессий через запятую в обратном порядке в формате iso8601
    report['usersStats'][user_key]['dates'] = report['usersStats'][user_key]['dates'].sort!.reverse!
  end

  report
end

def work(file = 'data.txt')
  report = parse_file(file)
  result_file_name = file == 'data.txt' ? 'result.json' : "#{file}.json"
  File.write(result_file_name,  "#{Oj.dump(report)}\n")
end



if ARGV.any?
  puts "process #{ARGV.first} ..."
  work(ARGV.first)
  puts "rss after #{print_memory_usage}"
else
  puts 'no file to process'
end
