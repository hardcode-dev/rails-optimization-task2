# Deoptimized version of homework task

require 'oj'
require 'pry'
require 'date'
require 'ruby-prof'
require 'stackprof'

require 'ruby-progressbar'

Dir[File.join(__dir__, 'class', '*.rb')].each { |file| require file }


COMMA = ','.freeze
SPACE = ' '.freeze
USER  = 'user'.freeze
COMMA_SPACE = ', '.freeze
SAPCE_MIN = ' min.'.freeze
EMPTY = ''.freeze
NEW_LINE =  "\n".freeze

def work(file)
  start = Time.now

  users = {}
  global_report = GlobalReport.new
  user = nil

  File.open('result.json', 'w') do |result_file|

    result_file.write('{"usersStats":{')

    File.readlines(file).each do |line|
      # fields = form_fields(line)

      fields = line.split(COMMA)

      if line.start_with?(USER)
        write_user_info(result_file, user, true) if user
        user = parse_user(fields)
        users[user.id] = user
      else
        parse_session(users, fields)
        global_report.process(fields)
      end
    end

    write_user_info(result_file, user, false)
    result_file.write('},')
    write_general_info(result_file, users, global_report)
    puts "MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)
    finish = Time.now

    diff = finish - start
    p diff
  end
end

def form_fields(line)
  test = []
  i = 0
  line_size = line.size
  end_size = line_size - 1
  start = 0
  while i <= line_size

    if line[i] == COMMA || i == end_size
      test << line[start..i - 1]
      start = i + 1
    end
    i += 1
  end

  test

  # array = []
  # word = ''
  # line.each_char do |sym|

  #   word << sym if sym != COMMA
  #   if sym == COMMA || sym == NEW_LINE
  #     array << word
  #     word = ''
  #   end
  # end
  # array
end

def parse_user(fields)
  User.new(
    fields[1],
    fields[2] << SPACE << fields[3],
    fields[4]
  )
end

def parse_session(users, fields)
  user_id = fields[1]
  user = users[user_id]
  user.sessions += 1
  user.report.process(fields[3].upcase!, fields[4].to_i, fields[5].strip)
end

def write_user_info(result_file, user, need_separator)
  result_file.write("\"#{user.name}\":")

  hash_report = {
    'sessionsCount'=> user.sessions,
    'totalTime'=> user.report.total_time.to_s << SAPCE_MIN,
    'longestSession'=> user.report.longest_session.to_s << SAPCE_MIN,
    'browsers'=> user.report.browsers.sort.join(COMMA_SPACE),
    'usedIE'=>  user.report.usedIE,
    'alwaysUsedChrome'=>  user.report.always_used_chrome,
    'dates'=> user.report.dates.sort!.reverse!
  }

  result_file.write(Oj.dump(hash_report))

  result_file.write(COMMA) if need_separator
end

def write_general_info(result_file, users, global_report)
  hash_report = {
    'totalUsers'=> users.count,
    'uniqueBrowsersCount'=> global_report.unique_browsers.count,
    'totalSessions'=> global_report.total_sessions,
    'allBrowsers'=> global_report.unique_browsers.sort.join(COMMA)
  }

  result_file.write(Oj.dump(hash_report)[1..])
end
