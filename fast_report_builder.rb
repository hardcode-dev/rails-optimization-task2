class FastReportBuilder
  def call(source_filename, report_filename)
    puts "~ 🚅 Fast Report Builder ~"

    # Build report without loading whole file to memory.
    build_report(source_filename, report_filename)

    puts "~ 🏁 Finished. MEMORY USAGE: #{memory_usage_mb} MB ~"
  end

  private

  def build_report(source_filename, report_filename)

    overall = {
      total_users: 0,
      total_sessions: 0,
      browsers_dict: {}
    }

    File.readlines("payloads/#{source_filename}").each do |line|
      cols = line.split(',')
      if cols[0] == 'user'
        overall[:total_users] = cols[1]
      end

      if cols[0] == 'session'
        overall[:total_sessions] += 1

        # Save info about browser
        browser_name = cols[3]
        overall[:browsers_dict][browser_name] = true
      end

    end

    report = build_meta(overall[:total_users], overall[:total_sessions], overall[:browsers_dict])

    puts
    puts " #{JSON.pretty_generate(report)}"
    puts

    File.write(report_filename, "#{report.to_json}\n")
  end

  # user,3,Kieth,Noble,20
  # session,3,0,Safari 23,1,2018-02-19
  # session,3,1,Internet Explorer 24,92,2018-05-15
  # session,3,2,Chrome 6,91,2017-01-06

  def build_meta(total_users, total_sessions, browsers_dict)
    {
      totalUsers: total_users.to_i + 1,  # users in file counted from zero
      totalSessions: total_sessions,
      uniqueBrowsersCount: browsers_dict.keys.count,
      allBrowsers: browser_list(browsers_dict),
      userStats: {}
    }
  end

  def browser_list(browser_dict)
    return "UNCOMMENT ME"

    # TODO: optimize this method if needed.
    list_arr = browser_dict.keys
    list_arr
      .sort
      .map { |b| b.upcase }
      .join(',')
  end

  # {
  #   "totalUsers": 91,
  #   "uniqueBrowsersCount": 183,
  #   "totalSessions": 509,
  #   "allBrowsers": "CHROME 1,CHROME 10",
  #   "usersStats": {
  #     "Hazel Margarete": {
  #       "sessionsCount": 8,
  #       "totalTime": "507 min.",
  #       "longestSession": "92 min.",
  #       "browsers": "CHROME 31, FIREFOX 13, FIREFOX 46, INTERNET EXPLORER 16, INTERNET EXPLORER 40, INTERNET EXPLORER 50, SAFARI 19, SAFARI 27",
  #       "usedIE": true,
  #       "alwaysUsedChrome": false,
  #       "dates": [
  #         "2019-02-04",
  #         "2018-02-01",
  #         "2017-11-30",
  #         "2017-11-21",
  #         "2017-10-28",
  #         "2017-05-31",
  #         "2016-11-02",
  #         "2016-08-22"
  #       ]
  #     },

  def memory_usage_mb
    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end
end