# frozen_string_literal: true

require 'json'
require 'set'

class Task2
  IE = 'INTERNET EXPLORER'
  CR = 'CHROME'

  def initialize(path = nil)
    @report = {
      totalUsers: 0,
      uniqueBrowsersCount: 0,
      totalSessions: 0,
      allBrowsers: Set.new
    }
    @user_stats = {
      sessionsCount: 0,
      totalTime: 0,
      longestSession: 0,
      browsers: [],
      usedIE: false,
      alwaysUsedChrome: false,
      dates: []
    }
    @user = {}
    @user_key = nil

    work(path)
  end

  private

  def work(path)
    path = path ? path : 'data_large.txt'

    output_file = File.open('result.json', 'w')
    output_file.write('{"usersStats":{')

    File.foreach(path) do |line|
      if line.start_with?('user')
        user_handler(output_file) if @user != {}

        _, _, name, surname = line.chomp!.split(',')

        @report[:totalUsers] += 1
        @user = {}
        reset_stats_structure
        @user_key = "#{name} #{surname}"
        @user[@user_key] = @user_stats
      else
        _, _, _, browser, session_time, date = line.chomp!.split(',')
        browser.upcase!
        session_time = session_time.to_i

        @report[:totalSessions] += 1
        @report[:allBrowsers] << browser

        @user[@user_key][:sessionsCount] += 1
        @user[@user_key][:totalTime] += session_time
        @user[@user_key][:longestSession] = session_time if @user[@user_key][:longestSession] < session_time
        @user[@user_key][:browsers] << browser
        @user[@user_key][:usedIE] = true if browser.start_with?(IE)
        @user[@user_key][:alwaysUsedChrome] = @user[@user_key][:browsers].all? { |b| b.start_with?(CR) } ? true : false
        @user[@user_key][:dates] << date
      end
    end

    user_handler(output_file, last_user: true)
    report_handler(output_file)
    output_file.close

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
  end

  def user_handler(output_file, last_user: false)
    @user[@user_key][:totalTime] = "#{@user[@user_key][:totalTime]} min."
    @user[@user_key][:longestSession] = "#{@user[@user_key][:longestSession]} min."
    @user[@user_key][:browsers] = @user[@user_key][:browsers].sort!.join(', ')
    @user[@user_key][:dates] = @user[@user_key][:dates].sort!.reverse!

    if last_user
      output_file.write("#{@user.to_json[1..-2]}")
    else
      output_file.write("#{@user.to_json[1..-2]},")
    end
  end

  def report_handler(output_file)
    @report[:uniqueBrowsersCount] = @report[:allBrowsers].size
    @report[:allBrowsers] = @report[:allBrowsers].sort.join(',')

    output_file.write("},#{@report.to_json[1..-1]}")
  end

  def reset_stats_structure
    @user_stats[:sessionsCount] = 0
    @user_stats[:totalTime] = 0
    @user_stats[:longestSession] = 0
    @user_stats[:browsers] = []
    @user_stats[:usedIE] = false
    @user_stats[:alwaysUsedChrome] = false
    @user_stats[:dates] = []
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
