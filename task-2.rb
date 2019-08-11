# frozen_string_literal: true

require 'set'
require 'oj'

USER = 'user'
SPLIT = ','
MIN = 'min.'
WS = ' '
COMMA = ', '
BROWSERS = %w[CHROME INTERNET\ EXPLORER].freeze
TMP_FILE = '.result.tmp'

def work(file)
  File.delete('result.json') if File.exist?('result.json')

  result_file = File.new("result.json", 'a:UTF-8')
  tmp_file    = File.new(TMP_FILE, 'a:UTF-8')
  report      = { 'totalUsers' => 0, 'uniqueBrowsersCount' => 0,
                  'totalSessions' => 0, 'allBrowsers' => Set.new, 'usersStats' => {} }

  # Скрапим и агрегируем данные
  scraping_data_file(file, tmp_file, report)
  aggregation_browser_data(report)

  # Если тут не закрыть tmp файл то читать будет не чего.
  tmp_file.close

  # Запись в файл
  report = "#{Oj.dump(report)}".delete_suffix("}}")
  result_file.write(report)
  need_name(result_file)

  # Подчищаем за собой мусор
  result_file.close
  File.delete(TMP_FILE)
end

private

def need_name(result_file)
  File.foreach(TMP_FILE) do |line|
    str = line.to_s.delete_suffix("\n")
    result_file.write(str)
  end

  result_file.write("}}\n")
end

def scraping_data_file(file, tmp_file, report)
  last_string = `wc -l #{file}`.split(WS)[0].to_i
  current_string = 0

  File.foreach(file) do |line|
    current_string += 1

    is_user = line.include?(USER)
    @user  = is_user ? user_name(line) : @user
    make_report(line, @user, is_user, report)

    save_interim_report(report, tmp_file, last_string, current_string)
  end
end

def save_interim_report(report, tmp_file, last_string, current_string)
  return unless last_string == current_string || report['usersStats'].keys.length > 1

  # Берем первого пользователя.
  # И причесываем его данные для предварительного сохранения во временный файл
  user_name   = report['usersStats'].keys[0]
  prepare_user_report(report, user_name)
  user_report = report['usersStats'][user_name]

  if last_string == current_string
    tmp_file.write("\"#{user_name}\":#{Oj.dump(user_report)}\n")
  else
    tmp_file.write("\"#{user_name}\":#{Oj.dump(user_report)},\n")
  end

  # После записи пользователя в файл. Пользователя из хеша report надо удалить
  report['usersStats'].tap { |users| users.delete(user_name) }
end

def user_name(line)
  n = line.split(SPLIT)
  "#{n[2]} #{n[3]}"
end

def browser_decoration(browsers)
  browsers.sort.join(SPLIT)
end

def make_report(line, user, is_user = false, report)
  if is_user
    report['usersStats'][user] = { 'sessionsCount' => 0,
                                   'totalTime' => 0,
                                   'longestSession' => 0,
                                   'browsers' => [],
                                   'usedIE' => false,
                                   'alwaysUsedChrome' => true,
                                   'dates' => ''.dup }
    report['totalUsers'] += 1
  else
    line.upcase!
    cols = line.split(SPLIT)
    i = 0

    while i < 6
      i += 1
      data = cols.shift

      case i
      when 4
        report['allBrowsers'] << data
        report['usersStats'][user]['alwaysUsedChrome'] = false if !report['usersStats'][user]['alwaysUsedChrome'] || !data.include?(BROWSERS[0])
        report['usersStats'][user]['usedIE'] = true if report['usersStats'][user]['usedIE'] || data.include?(BROWSERS[1])
        report['usersStats'][user]['browsers'] << data
      when 5
        report['usersStats'][user]['totalTime'] += data.to_i
        report['usersStats'][user]['longestSession'] = data.to_i if report['usersStats'][user]['longestSession'] < data.to_i
      when 6
        report['usersStats'][user]['dates'] << " #{data.chomp}"
      end
    end

    report['totalSessions'] += 1
    report['usersStats'][user]['sessionsCount'] += 1
  end
end

def aggregation_browser_data(report)
  report['uniqueBrowsersCount'] = report['allBrowsers'].length
  report['allBrowsers']         = report['allBrowsers'].sort.join(SPLIT)
end

def prepare_user_report(report, user)
  user = report['usersStats'][user]

  user['totalTime']      = "#{user['totalTime']} #{MIN}"
  user['browsers'].sort!
  user['browsers']       = user['browsers'].join(COMMA)
  user['longestSession'] = "#{user['longestSession']} #{MIN}"
  user['dates']          = user['dates'].split(WS).sort!.reverse
end

def print_memory_usage
  "%d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
end

# work('data_large.txt')

p print_memory_usage       # 16 MB =))