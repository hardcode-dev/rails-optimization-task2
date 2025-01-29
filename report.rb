class Report
  SPLITTER = ','.freeze
  USER_FLAG = 'user'.freeze
  SESSION_FLAG = 'session'.freeze

  def initialize(data_file, result_file)
    @data_file = data_file
    @result_file = result_file
    @users = 0
    @sessions = 0
    @browsers = SortedSet.new
    @temp_file = Tempfile.new('user_stats')
  end

  def generate
    @data_file.each_line(chomp: true) do |line|
      if line.start_with?(USER_FLAG)
        dump_user_stats if @user
        parse_user_from_line(line)
      end

      parse_session_from_line(line) if line.start_with?(SESSION_FLAG)
    end

    dump_user_stats if @user
    @user = nil

    @temp_file.close

    @result_file.print(start_template)

    @temp_file.open
    @temp_file.each_line(chomp: true) do |line|
      @result_file.print(line)
      @result_file.print(SPLITTER) unless @temp_file.eof?
    end

    @temp_file.close(true)
    @result_file.print('}}')
  end

  private

  def parse_user_from_line(line)
    fields = line.split(SPLITTER)[1..-1]
    @user = User.new(*fields)
    @users = @users.succ
  end

  def parse_session_from_line(line)
    fields = line.split(SPLITTER)[1..-1]
    session = Session.new(*fields)
    @user.sessions << session
    @browsers << session.browser
    @sessions = @sessions.succ
  end

  def dump_user_stats
    @temp_file.puts GenerateUserStat.call(@user)
  end

  def start_template
    "{\"totalUsers\":#{@users},\
    \"uniqueBrowsersCount\":#{@browsers.count},\
    \"totalSessions\":#{@sessions},\
    \"allBrowsers\":\"#{@browsers.to_a.join(',')}\",\
    \"usersStats\":{"
  end
end
