require_relative '../lib/task-2'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'task-1' do
  it 'works under 150ms' do
    expect {
      work('../data/data_4096.txt', disable_gc: false)
    }.to perform_under(150).ms.warmup(1).times.sample(5).times
  end
end
