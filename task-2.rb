# frozen_string_literal: true

require 'json'
require 'pry'
require 'date'

class Work
  def report_file
    @report_file ||= File.open('result.json', 'w')
  end

  def close_report_file
    @report_file.close
  end

  def write_user_to_report!
    @user_browsers.sort!
    @user_dates.sort!
    @user_dates.reverse!

    report_file.write <<JSON
"#{@user_first_name} #{@user_last_name}": {
  "sessionsCount": #{@user_sessions_count},
  "totalTime": "#{@user_total_time} min.",
  "longestSession": "#{@user_longest_session} min.",
  "browsers": "#{@user_browsers.join(', ')}",
  "usedIE": #{@user_used_ie},
  "alwaysUsedChrome": #{@user_always_used_chrome},
  "dates": ["#{@user_dates.join('","')}"]
}
JSON
  end

  def write_common_to_report!
    @total_browsers.sort!

    report_file.write <<JSON
},
  "uniqueBrowsersCount": #{@total_browsers.size},
  "totalSessions": #{@total_sessions},
  "totalUsers": #{@total_users},
  "allBrowsers": "#{@total_browsers.join(',')}"
}
JSON
  end

  def reset_user_vars!
    @user_sessions_count = 0
    @user_total_time = 0
    @user_longest_session = 0
    @user_browsers = []
    @user_used_ie = false
    @user_always_used_chrome = true
    @user_dates = []
  end

  def increase_user_vars!
    @user_sessions_count += 1
    @user_total_time += @current_session_time
    @user_longest_session = @current_session_time if @current_session_time > @user_longest_session
    @user_browsers << @current_session_browser
    unless @user_used_ie
      @user_used_ie = @current_session_browser.include? 'INTERNET EXPLORER'
    end
    if @user_always_used_chrome
      @user_always_used_chrome = @current_session_browser.include? 'CHROME'
    end
    @user_dates << @current_session_date
  end

  def work(file_path)
    @user_first_name = nil
    @user_last_name = nil
    @current_session_browser = nil
    @current_session_time = 0
    @current_session_date = ''
    @total_users = 0
    @total_sessions = 0
    @total_browsers = []

    report_file.write '{"usersStats":{'

    File.foreach(file_path) do |line|
      line.strip!
      i = 0
      # Исходя из примечания в задании:
      # Можем считать, что все сессии юзера всегда идут одним непрерывным куском.
      # Нет такого, что сначала идёт часть сессий юзера, потом сессии другого юзера, и потом снова сессии первого.
      if line.start_with? 'user'
        if @user_first_name && @user_last_name
          write_user_to_report!
          report_file.write ','
        end

        reset_user_vars!

        line.split(',') do |str|
          @user_first_name = str if i == 2
          @user_last_name = str if i == 3
          i += 1
        end

        @total_users += 1

      elsif line.start_with? 'session'
        line.split(',') do |str|
          @current_session_browser = str if i == 3
          @current_session_time = str.to_i if i == 4
          @current_session_date = str if i == 5
          i += 1
        end

        @current_session_browser.upcase!

        @total_sessions += 1
        @total_browsers << @current_session_browser unless @total_browsers.include?(@current_session_browser)

        increase_user_vars!
      end
    end

    write_user_to_report!
    write_common_to_report!

    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)

    close_report_file
  end
end


