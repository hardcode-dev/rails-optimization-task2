require 'json'
require 'date'
require 'set'

def work(file_path, gc_disable = false)
  GC.disable if gc_disable

  @users_count = 0
  sessions_count = 0
  uniq_browsers = Set.new

  result_file = 'data_files/result.json'

  File.open(result_file, 'w') do |f|
    f.write('{"usersStats":{')

    user_attrs = %i[type id first_name last_name age]
    session_attrs = %i[type user_id session_id browser time date]

    data_file = File.new(file_path)
    data_file.each do |line|
      next unless line.strip!

      line.split(',') do |val|
        if val == 'user'
          save_user_stats(f) if @users_count > 0

          @browsers = []
          @times = []
          @dates = []

          @line_type = :user
          @attr_pointer = 0

          @users_count += 1
        elsif val == 'session'
          @line_type = :session
          @attr_pointer = 0

          sessions_count += 1
        else
          @attr_pointer += 1

          current_attr = @line_type == :user ? user_attrs[@attr_pointer] : session_attrs[@attr_pointer]

          case current_attr
          when :first_name
            @first_name = val
          when :last_name
            @last_name = val
          when :browser
            @browsers << val
            uniq_browsers << val
          when :time
            @times << val
          when :date
            @dates << val
          end
        end
      end
    end

    if @dates.size > 0
      save_user_stats(f)
    end

    common_stats = '},'
    common_stats << "\"totalUsers\":#{@users_count},"
    common_stats << "\"uniqueBrowsersCount\":#{uniq_browsers.size},"
    common_stats << "\"totalSessions\":#{sessions_count},"

    all_browsers = uniq_browsers.map(&:upcase).sort.uniq.join(',')
    common_stats << "\"allBrowsers\":\"#{all_browsers}\"}"

    f.write(common_stats)
  end

  memery_usage = `ps -o rss= -p #{Process.pid}`.to_i / 1024
  puts "MEMORY USAGE: %d MB" % memery_usage

  memery_usage
end

def save_user_stats(f)
  f.write(',') if @users_count > 1
  f.write("\"#{@first_name} #{@last_name}\":{")

  str = "\"sessionsCount\":#{@dates.count},"

  total_time = @times.map { |t| t.to_i }.sum.to_s + ' min.'
  str << "\"totalTime\":\"#{total_time}\","

  longest_session = @times.map {|t| t.to_i}.max.to_s + ' min.'
  str << "\"longestSession\":\"#{longest_session}\","

  browsers = @browsers.map {|b| b.upcase}.sort.join(', ')
  str << "\"browsers\":\"#{browsers}\","

  used_ie = @browsers.any? { |b| b.upcase =~ /INTERNET EXPLORER/ }
  str << "\"usedIE\":#{used_ie},"

  only_chrome = @browsers.all? { |b| b.upcase =~ /CHROME/ }
  str << "\"alwaysUsedChrome\":#{only_chrome},"

  str << "\"dates\":#{@dates.sort!.reverse!}}"

  f.write(str)
end
