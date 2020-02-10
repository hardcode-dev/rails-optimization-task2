require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'file handler' do
    it 'works under 30s' do
      expect {
        work('data10000.txt', disable_gc: false)
      }.to perform_under(30000).ms.warmup(2).times.sample(10).times
    end
  end
end
