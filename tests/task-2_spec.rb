require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'uses under 20MB of memory' do
    expect do
      work('data/data.txt')
    end.to perform_allocation(41_000).bytes
  end

  it 'performs 20_000 under 0.05s' do
    expect do
      work('data/data20000.txt')
    end.to perform_under(50).ms.warmup(2).times.sample(5).times
  end
end
