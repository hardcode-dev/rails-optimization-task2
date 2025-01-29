# frozen_string_literal: true

# About:
# Отчёт в json
#   - По каждому пользователю
#     - сколько всего сессий +
#     - сколько всего времени +
#     - самая длинная сессия +
#     - браузеры через запятую +
#     - Хоть раз использовал IE? +
#     - Всегда использовал только Хром? +
#     - даты сессий в порядке убывания через запятую +
#   - Сколько всего юзеров +
#   - Сколько всего уникальных браузеров +
#   - Сколько всего сессий +
#   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +


# Optimized version of homework task
# task2 - $ ruby -r "./lib/optimization.rb" -e "Optimization.call" 'Optimization::TaskTwo' 'work' 'false,data/data.txt'

module Optimization
  require 'set'

  module TaskTwo
    extend self

    def work(path, gcl = nil)
      GC.disable if gcl

      @path ||= path
      @users = 0
      @browsers = SortedSet.new
      @sessions = 0

      file_write
    end

    private

    def file_write
      File.open('result.json', 'w') do |i|
        i.write('{"usersStats":{')

        file_read(i, @path)

        i.write("#{user_stats}},")
        i.write("#{collect_stats_for_users.to_json.gsub('{', '').gsub('}', '')}}\n")
      end
    end

    def file_read(outcome, path)
      File.foreach(path) do |j|
        cols = j.split(',')
        if cols[0] == 'user'
          outcome.write("#{user_stats},") unless @user.nil?

          @user = User.new(attributes: parse_user(cols), sessions: [])
          @users += 1
          next
        end
        @user.sessions << parse_session(cols)

        @browsers << cols[3].upcase
        @sessions += 1
      end
    end

    def collect_stats_for_users
      {
        'totalUsers' => @users,
        'uniqueBrowsersCount' => @browsers.count,
        'totalSessions' => @sessions,
        'allBrowsers' =>  @browsers.to_a.join(',')
      }
    end

    def user_stats
      "\"#{@user.attributes['first_name']} #{@user.attributes['last_name']}\":#{collect_stats_from_user.to_json}"
    end

    def parse_user(fields)
      {
        'id' => fields[1],
        'first_name' => fields[2],
        'last_name' => fields[3],
        'age' => fields[4]
      }
    end

    def parse_session(fields)
      {
        'user_id' => fields[1],
        'session_id' => fields[2],
        'browser' => fields[3].upcase,
        'time' => fields[4].to_i,
        'date' => fields[5][0..-2]
      }
    end

    def collect_stats_from_user
      {
        sessionsCount: @user.sessions.count,
        totalTime: @user.sessions.map { |s| s['time'] }.sum.to_s + ' min.',
        longestSession: @user.sessions.map { |s| s['time'] }.max.to_s + ' min.',
        browsers: @user.sessions.map { |s| s['browser'] }.sort.join(', '),
        usedIE: @user.sessions.map { |s| s['browser'] }.any? { |b| b =~ /INTERNET EXPLORER/ },
        alwaysUsedChrome: @user.sessions.map { |s| s['browser'] }.all? { |b| b =~ /CHROME/ },
        dates: @user.sessions.map { |s| s['date'] }.sort.reverse
      }
    end
  end
end



