# Deoptimized version of homework task

class ReportGenerator
  attr_reader :input, :output, :memory_usage

  def initialize(input:, output:)
    @input = input
    @output = output
    @memory_usage = nil

    @user_stats = {}
    @all_stats = {
      total_users: 0,
      total_sessions: 0,
      uniq_browsers: []
    }
  end

  def parse_line(line)
    @fields = line.split(',')

    if @fields[0] == 'user'
      collect_user(@fields)
    else
      collect_session(@fields)
    end
  end

  def collect_user(fields)
    dump_user
    @user_stats = {
      user_name: nil,
      sessions_count: 0,
      total_time: 0,
      longest_time: 0,
      browsers: [],
      used_ie: nil,
      always_user_chrome: true,
      dates: []
    }

    @user_stats[:user_name] = "#{fields[2]} #{fields[3]}"
    @all_stats[:total_users] += 1
  end

  def collect_session(fields)
    @all_stats[:total_sessions]+=1
    @all_stats[:uniq_browsers] << fields[3] unless @all_stats[:uniq_browsers].include?(fields[3].upcase!)

    @user_stats[:sessions_count] += 1
    @user_stats[:total_time] += fields[4].to_i
    @user_stats[:longest_time] = fields[4].to_i if fields[4].to_i > @user_stats[:longest_time]
    @user_stats[:browsers] << fields[3]
    @user_stats[:used_ie] ||= fields[3].include?('INTERNET EXPLORER')
    @user_stats[:always_user_chrome] &&= fields[3].include?('CHROME')
    @user_stats[:dates] << fields[5]
  end


  def dump_user
    unless @user_stats[:user_name]
      @out << '{"usersStats":{'
      return
    end

    @out << ',' if @all_stats[:total_users] > 1
    @out << "\"#{@user_stats[:user_name]}\":{\"sessionsCount\":#{@user_stats[:sessions_count]},"
    @out << "\"totalTime\":\"#{@user_stats[:total_time]} min.\","
    @out << "\"longestSession\":\"#{@user_stats[:longest_time]} min.\","
    @out << "\"browsers\":\"#{@user_stats[:browsers].sort.join(', ')}\","
    @out << "\"usedIE\":#{@user_stats[:used_ie]},"
    @out << "\"alwaysUsedChrome\":#{@user_stats[:always_user_chrome]},"
    @out << "\"dates\":[#{@user_stats[:dates].sort.reverse.map!{|d| "\"#{d}\""}.join(',')}]}"
  end

  def dump_end
    @out << "},\"totalUsers\":#{@all_stats[:total_users]},"
    @out << "\"uniqueBrowsersCount\":#{@all_stats[:uniq_browsers].size},"
    @out << "\"totalSessions\":#{@all_stats[:total_sessions]},"
    @out << "\"allBrowsers\":\"#{@all_stats[:uniq_browsers].sort.join(',')}\"}"
  end

  def work
    File.delete(output) if File.exist?(output)
    @out = File.open(output, 'w')

    File.open(input, 'r').each do |line|
      parse_line(line.chomp!)
    end
    dump_user
    dump_end
    @out.close

    @memory_usage = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "MEMORY USAGE: %d MB" % @memory_usage
  end
end

