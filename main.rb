class Main
  PARTIAL_VOLUME_FILE_NAME = "dataN.txt"

  def initialize(options: {})
    @source_file_name = options[:source_file_name] || 'data_large.txt'
    @count_lines = options[:count_lines]
    @current_user = nil
    @current_stat = nil
  end

  def call = work

  private

  attr_reader :source_file_name, :count_lines

  def work
    `head -n #{count_lines} #{source_file_name} > #{PARTIAL_VOLUME_FILE_NAME}` if count_lines
    
    report = {}
    sessions_count = 0
    users_count = 0
    uniq_browsers = Set.new

    File.open('result.json', 'w') do |result_file|
      result_file.write('{"usersStats":{')

      File.foreach(count_lines ? PARTIAL_VOLUME_FILE_NAME : source_file_name).each do |line|
        fields = line.split(',')
        case fields[0]
        when 'session'
          session = parse_session(fields)
          sessions_count += 1
          uniq_browsers.add(session['browser'])
          @current_stat = build_current_stat(@current_user, session)
        when 'user'
          write_user_stat(result_file)
          @current_user = parse_user(fields)
          @current_stat = build_initial_stat
          users_count += 1
        end
      end

      write_user_stat(result_file, with_delimeter: false)

      result_file.write("},\"totalUsers\":#{users_count},\"uniqueBrowsersCount\":#{uniq_browsers.count},\"totalSessions\":#{sessions_count},\"allBrowsers\":\"#{uniq_browsers.sort.join(',')}\"}\n")
    end
  end

  def write_user_stat(file, with_delimeter: true)
    return unless @current_user

    file.write("\"#{@current_user['key']}\":#{build_final_stat.to_json}")
    file.write(",") if with_delimeter

    @current_user = nil
  end

  def build_final_stat
    {
      'sessionsCount' => @current_stat['sessionsCount'],
      'totalTime' => "#{@current_stat['totalTime']} min.",
      'longestSession' => "#{@current_stat['longestSession']} min.",
      'browsers' => @current_stat['browsers'].sort.join(', '),
      'usedIE' => @current_stat['usedIE'],
      'alwaysUsedChrome' => @current_stat['alwaysUsedChrome'],
      'dates' => @current_stat['dates'].sort.reverse
    }
  end

  def build_current_stat(user, session)
    {
      'sessionsCount' => @current_stat['sessionsCount'] + 1,
      'totalTime' => @current_stat['totalTime'] + session['time'].to_i,
      'longestSession' => @current_stat['longestSession'] > session['time'] ? @current_stat['longestSession'] : session['time'],
      'browsers' => @current_stat['browsers'] << session['browser'],
      'usedIE' => @current_stat['usedIE'] ? true : !!(session['browser'] =~ /INTERNET EXPLORER/),
      'alwaysUsedChrome' => @current_stat['alwaysUsedChrome'] ? !!(session['browser'].upcase =~ /CHROME/) : false,
      'dates' => @current_stat['dates'] << Date.strptime(session['date'], '%Y-%m-%d').iso8601
    }
  end

  def build_initial_stat
    {
      'sessionsCount' => 0,
      'totalTime' => 0,
      'longestSession' => 0,
      'browsers' => [],
      'usedIE' => false,
      'alwaysUsedChrome' => true,
      'dates' => []
    }
  end

  def parse_user(fields)
    {
      'id' => fields[1],
      'first_name' => fields[2],
      'last_name' => fields[3],
      'age' => fields[4],
      'key' => "#{fields[2]} #{fields[3]}"
    }
  end
  
  def parse_session(fields)
    {
      'user_id' => fields[1],
      'session_id' => fields[2],
      'browser' => fields[3].upcase,
      'time' => fields[4].to_i,
      'date' => fields[5],
    }
  end
end
