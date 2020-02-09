require_relative 'spec_helper'
require 'pry'
require_relative '../lib/optimization'

def linear_work(size)
  a = []
  size.times { a << nil }
end

describe 'work' do
  before { FileUtils.rm_f('result.json') }
  subject { Optimization::TaskTwo.work('tests/fixtures/data.txt', false) }

  describe 'regression' do
    let(:result) { File.read('result.json') }
    let(:example) { File.read('tests/fixtures/result.json') }
    before { subject }

    it 'the result should eq fixture' do
      expect(result).to have_json_size(3).at_path('usersStats')
      expect(result).to be_json_eql(JSON.parse(result)['allBrowsers'].to_json).at_path('allBrowsers')
      expect(result).to be_json_eql(JSON.parse(result)['usersStats']['Leida Cira'].to_json)
                          .at_path('usersStats/Leida Cira')
    end
  end

  describe 'performance' do
    it 'works under 0.07 ms' do
      expect do
        linear_work(subject)
      end.to perform_under(0.07).ms.warmup(2).times.sample(10).times
    end
  end

  describe 'memory usage' do
    let!(:mem_before) { `ps -o rss= -p #{Process.pid}`.to_i / 1024 }
    let(:mem_after) { `ps -o rss= -p #{Process.pid}`.to_i / 1024 }

    it 'mem size before and after subject should less then 10 ' do
      subject
      expect(mem_after - mem_before).to be < 10
    end

    it 'mem size before and after subject should greater then 5' do
      subject
      expect(mem_after - mem_before).to_not be > 8
    end
  end
end
