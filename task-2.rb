# frozen_string_literal: true

# Deoptimized version of homework task
require 'oj'
require 'set'

Oj.default_options = {mode: :strict }

class Work

  attr_accessor :report

  def initialize(filename)
    @filename = filename

    @report = {}
    @user_stats = {}

    @unique_browsers = SortedSet.new

    @users_count = 0
    @cur_user_stats = { }

    @file = File.open('result.json', 'w')

    @sessions_count = 0
    @first_user = true
  end

  def close_file
    @file.close
  end

  def write_to_file(text)
    @file.write(text)
  end

  def write_head
    write_to_file('{"usersStats":{')
  end

  def finalize_user

    @cur_user_stats.each do |user_name, stats|
      stats[:totalTime] = "#{stats[:totalTime]} min."
      stats[:longestSession] = "#{stats[:longestSession]} min."
      stats[:browsers] = stats[:browsers].sort.join(', ')
      stats[:dates] = stats[:dates].to_a.reverse


      write_to_file("#{@first_user ? '' : ','}\"#{user_name}\":")
      write_to_file(Oj.dump(stats))

      @first_user = false
    end


    @cur_user_stats = {}
  end

  def finalize
    finalize_user # finalize last user

    write_to_file("}, \"totalUsers\":#{@users_count},")
    write_to_file("\"totalSessions\":#{@sessions_count},")
    write_to_file("\"uniqueBrowsersCount\":#{@unique_browsers.count},")
    write_to_file("\"allBrowsers\":\"#{@unique_browsers.to_a.join(',')}\"}")

    close_file
  end

  def parse_user(fields)

    @users_count += 1
    finalize_user

    name = "#{fields[2]} #{fields[3]}"

    @cur_user_stats[name] = {
        sessionsCount:  0,
        totalTime:  0,
        longestSession:  0,
        browsers:  [],
        usedIE:  false,
        alwaysUsedChrome:  true,
        dates:  SortedSet.new
    }

  end


  def parse_session(fields)

    @sessions_count += 1

    stats = @cur_user_stats.values.last # cause we only have one

    stats[:sessionsCount] += 1

    time = fields[4].to_i

    stats[:totalTime] += time
    stats[:longestSession] = time if time > stats[:longestSession]

    stats[:dates].add(fields[5].chomp)

    browser = fields[3].upcase
    @unique_browsers.add(browser)
    stats[:usedIE] ||= !browser['INTERNET EXPLORER'].nil?
    stats[:browsers] << browser
    stats[:alwaysUsedChrome] &&= !browser['CHROME'].nil?


  end

  def work
    write_head


    File.open(@filename,'r').each do |line|
      cols = line.split(',')

      if cols[0] == 'session'
        parse_session(cols)
      elsif cols[0] == 'user'
        parse_user(cols)
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


    finalize

  end
end
