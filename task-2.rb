require 'set'
require 'multi_json'
require 'minitest/autorun'
# require 'memory_profiler'
# require 'stackprof'
# require 'ruby-prof'

def work(file_name)
  start_time = Time.now
  users_count = 0
  sessions = 0
  unique_browsers = Set.new([])
  tmp_file = File.open('tmp.txt', 'w')
  tmp_file.write('{')
  File.open(file_name).each("\nuser,") do |raw_line|
    user_sessions = raw_line.split("\nsession,").map { |x| x.split(',') }
    user = user_sessions.shift
    user.shift if user[0] == 'user'
    sessions_time    = []
    sessions_browser = []
    sessions_date    = []
    user_sessions.map! do |session|
      sessions += 1
      unique_browsers.add session[2].upcase
      sessions_browser << session[2].upcase
      sessions_time    << session[3].to_i
      sessions_date    << session[4].delete("\nuser")
      {browser: session[2].upcase, time: session[3].to_i, date: session[4]}
    end
    user_stats = MultiJson.dump(
      sessionsCount: user_sessions.length,
      totalTime: "#{sessions_time.sum} min.",
      longestSession: "#{sessions_time.max} min.",
      browsers: sessions_browser.sort!.join(', '),
      usedIE: sessions_browser.any? { |b| b[0] == 'I' },
      alwaysUsedChrome: sessions_browser.all? { |b| b[0] == 'C' },
      dates: sessions_date.sort!.reverse
    )
    tmp_file.write("\"#{user[1..2].join(' ')}\":#{user_stats}#{user_sessions.last[:date].size > 11 ? ',' : '}'}\n")
    users_count += 1
  end
  tmp_file.close
  report = MultiJson.dump(totalUsers: users_count, uniqueBrowsersCount: unique_browsers.length, totalSessions: sessions, allBrowsers: unique_browsers.sort.join(','))
  report[-1] = ',"usersStats":'
  result_file = File.open('result.json', 'w')
  result_file << report
  IO.foreach(tmp_file) { |line| result_file << line.chomp }
  result_file << "}\n"
  result_file.close
  puts "Memory: %d kbyte." % (`ps -o rss= -p #{Process.pid}`)
  puts "Time: #{Time.now - start_time} sec."
end

class TestMe < Minitest::Test
  def test_result
    work('data.txt')
    assert_equal File.read('expected.json'), File.read('result.json')
  end
end

# MemoryProfiler.report { work('data_small.txt') }.pretty_print(scale_bytes: true)

# StackProf.run(node: :object, out: 'reports/stackprof.dump', raw: true) { work('data_small.txt') }
# stackprof = StackProf.run(node: :object, raw: true) { work('data_small.txt') }
# File.write('reports/stackprof.json', MultiJson.dump(stackprof))

# RubyProf.measure_mode = RubyProf::ALLOCATIONS
# result = RubyProf.profile { work('data_small.txt') }
# RubyProf::FlatPrinter.new(result).print(File.open('reports/ruby_prof_flat.txt', 'w+'))
# RubyProf::DotPrinter.new(result).print(File.open('reports/ruby_prof_graphviz.dot', 'w+'))
# RubyProf::GraphHtmlPrinter.new(result).print(File.open('reports/ruby_prof_graph.html', 'w+'))
# RubyProf::CallStackPrinter.new(result).print(File.open('reports/ruby_prof_callstack.html', 'w+'))

# RubyProf.measure_mode = RubyProf::MEMORY
# result = RubyProf.profile { work('data_small.txt') }
# RubyProf::CallTreePrinter.new(result).print(path: 'reports', profile: 'profile')

work('data_large.txt')
