# frozen_string_literal: true
require 'date'

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

class GenerateReport
  def work(path)
    @user_counter = 0
    @sessions_counter = 0
    @uniq_browsers = []

    File.open('result.json', 'a') do |file|
      file << '{"usersStats":{'
    end

    data_file = File.open(path)

    data_file.each do |line|
      case line[0]
      when 'u'
        process_user(line)
      when 's'
        process_session(line)
      else
        next
      end
    end

    data_file.close

    fill_last_user_data
    wrote_down_common_info
    
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  private

  def process_user(line)
    fill_user_data unless first_user?

    @user = parse_user(line)
    @sessions = []
    @user_counter += 1
  end

  def fill_user_data
    File.open('result.json', 'a') do |file|
      file << "#{form_user_stat}, "
    end
  end

  def form_user_stat
    user_info = {}
    user_key = "#{@user['first_name']} #{@user['last_name']}"

    user_info["sessionsCount"] = @sessions.count
    user_info["totalTime"] = @sessions.map {|s| s['time']}.sum.to_s + ' min.'
    user_info["longestSession"] = @sessions.map {|s| s['time']}.max.to_s + ' min.'
    user_info["browsers"] = @sessions.map {|s| s['browser']}.sort.join(', ')
    user_info["usedIE"] = @sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ }
    user_info["alwaysUsedChrome"] = @sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ }
    user_info["dates"] = @sessions.map{|s| s['date']}.map {|d| Date.parse(d)}.sort.reverse.map { |d| d.iso8601 }

    "\"#{user_key}\": #{user_info.to_json}"
  end

  def first_user?
    @user_counter.zero?
  end

  def parse_user(line)
    fields = line.split(',')
    parsed_result = {
      'id' => fields[1].to_i,
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
    }
  end

  def process_session(line)
    session = parse_session(line)

    @sessions << session
    @uniq_browsers << session['browser'] unless @uniq_browsers.include?(session['browser'])
    @sessions_counter += 1
  end

  def parse_session(line)
    fields = line.split(',')
    parsed_result = {
      'user_id' => fields[1].to_i,
      'session_id' => fields[2],
      'browser' => fields[3].upcase,
      'time' => fields[4].to_i,
      'date' => fields[5],
    }
  end

  def fill_last_user_data
    last_stats = form_user_stat

    File.open('result.json', 'a') do |file|
      file << last_stats
    end
  end

  def wrote_down_common_info
    common_info = " }, \"totalUsers\": #{@user_counter}, \"uniqueBrowsersCount\": #{@uniq_browsers.count}, \"totalSessions\": #{@sessions_counter}, \"allBrowsers\": \"#{@uniq_browsers.sort.join(',')}\" }"

    File.open('result.json', 'a') do |file|
      file << common_info
    end
  end
end
