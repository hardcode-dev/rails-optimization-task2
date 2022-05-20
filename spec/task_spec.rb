# frozen_string_literal: true

require './spec_helper'
require './task-2'

RSpec.describe 'Task testing.' do
  describe 'Result.' do
    let(:leida_cira) do
      {
        'sessionsCount'    => 6,
        'totalTime'        => '455 min.',
        'longestSession'   => '118 min.',
        'browsers'         => 'FIREFOX 12, INTERNET EXPLORER 28, INTERNET EXPLORER 28, ' \
                              'INTERNET EXPLORER 35, SAFARI 29, SAFARI 39',
        'usedIE'           => true,
        'alwaysUsedChrome' => false,
        'dates'            => %w[2017-09-27 2017-03-28  2017-02-27 2016-10-23 2016-09-15 2016-09-01]
      }
    end

    let(:palmer_katrina) do
      {
        'sessionsCount'    => 5,
        'totalTime'        => '218 min.',
        'longestSession'   => '116 min.',
        'browsers'         => 'CHROME 13, CHROME 6, FIREFOX 32, INTERNET EXPLORER 10, SAFARI 17',
        'usedIE'           => true,
        'alwaysUsedChrome' => false,
        'dates'            => %w[2017-04-29 2016-12-28 2016-12-20 2016-11-11 2016-10-21]
      }
    end

    let(:gregory_santos) do
      {
        'sessionsCount'    => 4,
        'totalTime'        => '192 min.',
        'longestSession'   => '85 min.',
        'browsers'         => 'CHROME 20, CHROME 35, FIREFOX 47, SAFARI 49',
        'usedIE'           => false,
        'alwaysUsedChrome' => false,
        'dates'            => %w[2018-09-21 2018-02-02 2017-05-22 2016-11-25]
      }
    end

    let(:browsers) do
      [
        'CHROME 13', 'CHROME 20', 'CHROME 35', 'CHROME 6',
        'FIREFOX 12', 'FIREFOX 32', 'FIREFOX 47',
        'INTERNET EXPLORER 10', 'INTERNET EXPLORER 28', 'INTERNET EXPLORER 35',
        'SAFARI 17', 'SAFARI 29', 'SAFARI 39', 'SAFARI 49'
      ].join(',')
    end

    let(:list) do
      <<-TXT
user,0,Leida,Cira,0
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
      TXT
    end

    subject { File.read('result.json') }

    before do
      File.write('result.json', '')
      File.write('data.txt', list)

      App.new('data.txt').work
    end

    it 'should build report of user sessions' do
      is_expected.to be_json_eql(3).at_path('totalUsers')
      is_expected.to be_json_eql(14).at_path('uniqueBrowsersCount')
      is_expected.to be_json_eql(15).at_path('totalSessions')
      is_expected.to be_json_eql(browsers.to_json).at_path('allBrowsers')
      is_expected.to be_json_eql(leida_cira.to_json).at_path('usersStats/Leida Cira')
      is_expected.to be_json_eql(palmer_katrina.to_json).at_path('usersStats/Palmer Katrina')
      is_expected.to be_json_eql(gregory_santos.to_json).at_path('usersStats/Gregory Santos')
    end
  end

  it { expect { App.new('data_large.txt').work }.to perform_under(30).sec }

  context 'Memory.' do
    it { expect(diff_memory_usage { App.new('data_large.txt').work }).to be <= 30 }

    def memory_usage
      `ps -o rss= -p #{Process.pid}`.to_i / 1024
    end

    def diff_memory_usage
      before = memory_usage
      yield
      after = memory_usage
      after - before
    end
  end
end
