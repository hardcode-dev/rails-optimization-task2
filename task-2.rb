require 'oj'
require 'pry'
require 'date'
require 'minitest/autorun'

COMMA = ','.freeze
COMMA_SP = ', '.freeze
MIN = ' min.'.freeze
IE = 'INTERNET EXPLORER'.freeze

def work(file = 'data.txt', disable_gc: false)
  GC.disable if disable_gc

  @result_json = {
    'totalUsers' => 0,
    'uniqueBrowsersCount' => 0,
    'totalSessions' => 0,
    'allBrowsers' => [],
    'usersStats' => {}
  }

  File.foreach(file) do |row|
    row.strip!
    cols = row.split(COMMA)

    case cols[0]
    when 'user'
      if @user_key && @result_json['usersStats'][@user_key]
        @result_json['usersStats'][@user_key]['dates'].sort!.reverse!
        @result_json['usersStats'][@user_key]['browsers'] = @result_json['usersStats'][@user_key]['browsers'].sort.join(COMMA_SP)
        @result_json['usersStats'][@user_key]['totalTime'] = @result_json['usersStats'][@user_key]['totalTime'].to_s << MIN
        @result_json['usersStats'][@user_key]['longestSession'] = @result_json['usersStats'][@user_key]['longestSession'].to_s << MIN
      end

      @user_key = "#{cols[2]} #{cols[3]}"
      @result_json['totalUsers'] += 1
      @result_json['usersStats'][@user_key] =
        {
        'sessionsCount' => 0,
        'totalTime' => 0,
        'longestSession' => 0,
        'browsers' => [],
        'usedIE' => false,
        'alwaysUsedChrome' => true,
        'dates' => []
      }
    when 'session'
      @result_json['totalSessions'] += 1

      cols[3].upcase!
      @result_json['allBrowsers'] << cols[3] unless @result_json['allBrowsers'].include? cols[3]

      @result_json['usersStats'][@user_key]['sessionsCount'] += 1

      @result_json['usersStats'][@user_key]['totalTime'] += cols[4].to_i

      if (c = cols[4].to_i) > @result_json['usersStats'][@user_key]['longestSession']
        @result_json['usersStats'][@user_key]['longestSession'] = c
      end

      @result_json['usersStats'][@user_key]['browsers'] << cols[3]

      if !@result_json['usersStats'][@user_key]['usedIE'] && cols[3].start_with?(IE)
        @result_json['usersStats'][@user_key]['usedIE'] = true
      end

      if @result_json['usersStats'][@user_key]['alwaysUsedChrome'] && !cols[3].start_with?('CHROME')
        @result_json['usersStats'][@user_key]['alwaysUsedChrome'] = false
      end

      @result_json['usersStats'][@user_key]['dates'] << cols[5]
    end
  end

  if @user_key && @result_json['usersStats'][@user_key]
    @result_json['usersStats'][@user_key]['dates'].sort!.reverse!
    @result_json['usersStats'][@user_key]['browsers'] = @result_json['usersStats'][@user_key]['browsers'].sort.join(COMMA_SP)
    @result_json['usersStats'][@user_key]['totalTime'] = @result_json['usersStats'][@user_key]['totalTime'].to_s << MIN
    @result_json['usersStats'][@user_key]['longestSession'] = @result_json['usersStats'][@user_key]['longestSession'].to_s << MIN
  end

  @result_json['uniqueBrowsersCount'] = @result_json['allBrowsers'].size
  @result_json['allBrowsers'] = @result_json['allBrowsers'].sort.join(COMMA)

  # @result_json['usersStats'].keys.each do |user_key|
  #   @result_json['usersStats'][user_key]['dates'].sort!.reverse!
  #   @result_json['usersStats'][user_key]['browsers'] = @result_json['usersStats'][user_key]['browsers'].sort.join(COMMA_SP)
  #   @result_json['usersStats'][user_key]['totalTime'] = @result_json['usersStats'][user_key]['totalTime'].to_s << MIN
  #   @result_json['usersStats'][user_key]['longestSession'] = @result_json['usersStats'][user_key]['longestSession'].to_s << MIN
  # end



  # Отчёт в json
  #   - Сколько всего юзеров +
  #   - Сколько всего уникальных браузеров +
  #   - Сколько всего сессий +
  #   - Перечислить уникальные браузеры в алфавитном порядке через запятую и капсом +
  #
  #   - По каждому пользователю
  #     - сколько всего сессий +
  #     - сколько всего времени +
  #     - самая длинная сессия +
  #     - браузеры через запятую +
  #     - Хоть раз использовал IE? +
  #     - Всегда использовал только Хром? +
  #     - даты сессий в порядке убывания через запятую +


  File.write('result.json', "#{Oj.dump(@result_json)}\n")
end

class TestMe < Minitest::Test
  def setup
    File.write('result.json', '')
    File.write('data.txt',
               'user,0,Leida,Cira,0
session,0,0,Safari 29,87,2016-10-23
session,0,1,Firefox 12,118,2017-02-27
session,0,2,Internet Explorer 28,31,2017-03-28
session,0,3,Internet Explorer 28,109,2016-09-15
session,0,4,Safari 39,104,2017-09-27
session,0,5,Internet Explorer 35,6,2016-09-01
user,1,Palmer,Katrina,65
session,1,0,Safari 17,12,2016-10-21
session,1,1,Firefox 32,3,2016-12-20
session,1,2,Chrome 6,59,2016-11-11
session,1,3,Internet Explorer 10,28,2017-04-29
session,1,4,Chrome 13,116,2016-12-28
user,2,Gregory,Santos,86
session,2,0,Chrome 35,6,2018-09-21
session,2,1,Safari 49,85,2017-05-22
session,2,2,Firefox 47,17,2018-02-02
session,2,3,Chrome 20,84,2016-11-25
')
  end

  def test_result
    work
    expected_result = "{\"totalUsers\":3,\"uniqueBrowsersCount\":14,\"totalSessions\":15,\"allBrowsers\":\"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49\",\"usersStats\":{\"Leida Cira\":{\"sessionsCount\":6,\"totalTime\":\"455 min.\",\"longestSession\":\"118 min.\",\"browsers\":\"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39\",\"usedIE\":true,\"alwaysUsedChrome\":false,\"dates\":[\"2017-09-27\",\"2017-03-28\",\"2017-02-27\",\"2016-10-23\",\"2016-09-15\",\"2016-09-01\"]},\"Palmer Katrina\":{\"sessionsCount\":5,\"totalTime\":\"218 min.\",\"longestSession\":\"116 min.\",\"browsers\":\"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17\",\"usedIE\":true,\"alwaysUsedChrome\":false,\"dates\":[\"2017-04-29\",\"2016-12-28\",\"2016-12-20\",\"2016-11-11\",\"2016-10-21\"]},\"Gregory Santos\":{\"sessionsCount\":4,\"totalTime\":\"192 min.\",\"longestSession\":\"85 min.\",\"browsers\":\"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49\",\"usedIE\":false,\"alwaysUsedChrome\":false,\"dates\":[\"2018-09-21\",\"2018-02-02\",\"2017-05-22\",\"2016-11-25\"]}}}\n"
    assert_equal expected_result, File.read('result.json')
  end
end
