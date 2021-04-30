# Deoptimized version of homework task

require 'json'
require 'byebug'
require 'date'
require 'minitest/autorun'

class User
  attr_reader :attributes, :sessions

  def initialize(attributes:, sessions:)
    @attributes = attributes
    @sessions = sessions
  end

  def key
    "#{attributes['first_name']} #{attributes['last_name']}"
  end
end

class ReportGenerate
  def initialize
    @browsers = []
    @report = {
      'totalUsers' => 0,
      'totalSessions' => 0,
      'usersStats' => {}
    }
  end

  def work(filename)
    #users = []
    #sessions = []

    IO.foreach(filename) do |line|
      line.strip!

      cols = line.split(',')

      handle_user(cols) if cols[0] == 'user'
      handle_session(cols) if cols[0] == 'session'
    end

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

    browsers.sort!.uniq!
    report['allBrowsers'] = browsers.join(',')
    report['uniqueBrowsersCount'] = browsers.length

    File.write('result.json', "#{report.to_json}\n")
  end

  private

  attr_reader :report, :browsers, :users_stats, :current_user

  def parse_user(user)
    {
      'id' => user[1],
      'first_name' => user[2],
      'last_name' => user[3],
      'age' => user[4],
    }
  end

  def parse_session(session)
    {
      'user_id' => session[1],
      'session_id' => session[2],
      'browser' => session[3].upcase,
      'time' => session[4].to_i,
      'date' => session[5],
    }
  end

  def handle_user(user)
    report['totalUsers'] += 1

    @current_user = User.new(attributes: parse_user(user), sessions: [])
    
    report['usersStats'][current_user.key] = {}
    report['usersStats'][current_user.key].merge!({
                                           'sessionsCount' => 0,
                                           'totalTime' => '',
                                           'longestSession' => '',
                                           'browsers' => '',
                                           'usedIE' => '',
                                           'alwaysUsedChrome' => '',
                                           'dates' => '',
                                         })
  end

  def handle_session(session)
    report['totalSessions'] += 1
    session_data = parse_session(session)
    browsers << session_data['browser']

    current_user.sessions << session_data

    report['usersStats'][current_user.key]['sessionsCount'] += 1
    report['usersStats'][current_user.key]['totalTime'] = current_user.sessions.map {|s| s['time']}.sum.to_s + ' min.'
    report['usersStats'][current_user.key]['longestSession'] = current_user.sessions.map {|s| s['time']}.max.to_s + ' min.'
    report['usersStats'][current_user.key]['browsers'] = current_user.sessions.map {|s| s['browser']}.sort.join(', ')
    report['usersStats'][current_user.key]['usedIE'] = current_user.sessions.map{|s| s['browser']}.any? { |b| b =~ /INTERNET EXPLORER/ }
    report['usersStats'][current_user.key]['alwaysUsedChrome'] = current_user.sessions.map{|s| s['browser']}.all? { |b| b =~ /CHROME/ }
    report['usersStats'][current_user.key]['dates'] = current_user.sessions.map{|s| s['date']}.sort.reverse
  end
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
    ReportGenerate.new.work('data.txt')
    expected_result = JSON.parse('{"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13,CHROME 20,CHROME 35,CHROME 6,FIREFOX 12,FIREFOX 32,FIREFOX 47,INTERNET EXPLORER 10,INTERNET EXPLORER 28,INTERNET EXPLORER 35,SAFARI 17,SAFARI 29,SAFARI 39,SAFARI 49","usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}}}')
    assert_equal expected_result, JSON.parse(File.read('result.json'))
  end
end
