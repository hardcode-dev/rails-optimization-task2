require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'work' do
    # 100 lines under 6.9 milliseconds
    it 'should work under 6.9 milliseconds' do
      expect { work('data100.txt') }.to perform_under(6.9).ms.warmup(2).times.sample(10).times
    end

    # 1000 lines under 8.9 milliseconds
    it 'should work under 8.9 milliseconds' do
      expect { work('data1000.txt') }.to perform_under(8.9).ms.warmup(2).times.sample(10).times
    end

    # 10000 lines under 33 milliseconds
    it 'should work under 33 milliseconds' do
      expect { work('data10000.txt') }.to perform_under(33).ms.warmup(2).times.sample(10).times
    end

    let(:measurement_time_seconds) { 1 }
    let(:warmup_time_seconds) { 0.2 }
    it 'works faster than 170 ips' do
      expect { work('data100.txt') }.to perform_at_least(170).within(measurement_time_seconds).warmup(warmup_time_seconds).ips
    end

    it 'performs linear' do
      expect { |n, _i| work("data#{n}.txt") }.to perform_linear.in_range(1000, 8000).ratio(2)
    end
  end
end
