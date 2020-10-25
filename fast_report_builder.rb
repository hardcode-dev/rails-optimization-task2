class FastReportBuilder
  USED_MEMORY_LIMIT_MB = 25
  USER_STATS_FILE = 'temp_user_stats.json'

  def call(source_filename, report_filename)
    puts "~ 🚅 Fast Report Builder ~"

    # Build report without loading whole file to memory.
    build_report(source_filename, report_filename)

    puts "~ 🏁 Finished. MEMORY USAGE: #{memory_usage_mb} MB ~"
  end

  private

  def reset_user(single_user)
    single_user[:name] = ''
    single_user[:sessions_count] = 0
    single_user[:total_time] = 0
    single_user[:longest_session] = 0
    single_user[:browsers] = {}
    single_user[:used_ie] = false
    single_user[:always_chrome] = true
    single_user[:dates_arr] = []
  end

  def serialize_user(single_user)
    {
      'sessionsCount' => single_user[:sessions_count],
      'totalTime' => single_user[:total_time].to_s + ' min.'.freeze,
      'longestSession' => single_user[:longest_session].to_s + ' min.'.freeze,
      'browsers' => single_user[:browsers].keys.sort.join(', '),
      'usedIE' => single_user[:used_ie],
      'alwaysUsedChrome' => single_user[:always_chrome],
      'dates' => single_user[:dates_arr].sort.reverse
    }
  end

  def write_previous_user(single_user)
    # TODO: append to the end of file here.
    puts " user: #{single_user[:name]}, sessions: #{single_user[:sessions_count]}, used_id: #{single_user[:used_ie]}"

    serialized = serialize_user(single_user)

    File.open(USER_STATS_FILE,"w") do |f|
      f.puts serialized.to_json
    end
  end

  def populate_single_user(single_user, cols) # cols stands for 'session line cols'
    browser_name = cols[3].upcase
    time = cols[4].to_i
    date = cols[5]

    single_user[:sessions_count] += 1
    single_user[:total_time] += time
    single_user[:longest_session] = time if time > single_user[:longest_session]
    single_user[:browsers][browser_name] = true

    unless single_user[:used_ie]
      bool_ie = browser_name.upcase =~ /INTERNET EXPLORER/
      if bool_ie
        single_user[:used_ie]= true
        single_user[:always_chrome] = false
      end
    end

    if single_user[:always_chrome]
      bool_chrome = browser_name.upcase =~ /CHROME/
      single_user[:always_chrome] = false unless bool_chrome
    end

    single_user[:dates_arr] << date
  end

  def build_report(source_filename, report_filename)

    overall = {
      total_users: 0,
      total_sessions: 0,
      browsers_dict: {}
    }

    single_user = {
      name: '',
      sessions_count: 0,
      total_time: 0,
      longest_session: 0,
      browsers: {},
      used_ie: false,
      always_chrome: true,
      dates: []
    }

    File.readlines("payloads/#{source_filename}").each do |line|
      cols = line.gsub("\n", '').split(',')

      if cols[0] == 'user'
        write_previous_user(single_user) if single_user[:name] != '' # don't write first user, its empty anyway.
        reset_user(single_user)

        overall[:total_users] = cols[1]
        single_user[:name] = "#{cols[2]} #{cols[3]}"
      end

      if cols[0] == 'session'
        overall[:total_sessions] += 1

        # Save info about browser
        browser_name = cols[3].upcase
        overall[:browsers_dict][browser_name] = true

        # Save info related to current user.
        populate_single_user(single_user, cols)

      end
    end

    # don't forget about last user.
    write_previous_user(single_user)

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
    usage_mb = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    if usage_mb > USED_MEMORY_LIMIT_MB
      puts "❌ memory usage is #{usage_mb}"
    end

    usage_mb
  end
end