require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Quality' do
  it 'process data.txt correctly' do
    work('data.txt')
    expected_result = '{"usersStats":{"Leida Cira":{"sessionsCount":6,"totalTime":"455 min.","longestSession":"118 min.","browsers":"FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 29, SAFARI 39","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-09-27","2017-03-28","2017-02-27","2016-10-23","2016-09-15","2016-09-01"]},"Palmer Katrina":{"sessionsCount":5,"totalTime":"218 min.","longestSession":"116 min.","browsers":"CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17","usedIE":true,"alwaysUsedChrome":false,"dates":["2017-04-29","2016-12-28","2016-12-20","2016-11-11","2016-10-21"]},"Gregory Santos":{"sessionsCount":4,"totalTime":"192 min.","longestSession":"85 min.","browsers":"CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49","usedIE":false,"alwaysUsedChrome":false,"dates":["2018-09-21","2018-02-02","2017-05-22","2016-11-25"]}},"totalUsers":3,"uniqueBrowsersCount":14,"totalSessions":15,"allBrowsers":"CHROME 13, CHROME 20, CHROME 35, CHROME 6, FIREFOX 12, FIREFOX 32, FIREFOX 47, INTERNET EXPLORER 10, INTERNET EXPLORER 28, INTERNET EXPLORER 35, SAFARI 17, SAFARI 29, SAFARI 39, SAFARI 49"}' + "\n"
    expect(File.read('result.json')).to eq expected_result
  end
end

describe 'Memory usage' do
  it 'lower than 30 MB on 100K records' do
    m_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work('data_100K.txt')
    m_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(m_after - m_before).to be <= 30
  end
  it 'lower than 30 MB on 1000K records' do
    m_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work('data_1000K.txt')
    m_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(m_after - m_before).to be <= 30
  end
end