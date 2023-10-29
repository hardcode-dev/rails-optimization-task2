require_relative '../task-2'
require 'rspec'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'perfomance' do
  it 'performs under certain time' do
    expect { work(filename: 'data1000000.txt') }.to perform_under(3_300).ms.warmup(1).times
  end

  it 'limits allocation size' do
    expect(work(filename: 'data1000000.txt')[:used_memory]).to be <= 32
  end
end
