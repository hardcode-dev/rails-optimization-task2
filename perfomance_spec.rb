require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'works under 220 ms' do
    expect {
      work('data25000.txt', 'result.json')
    }.to perform_under(220).ms.warmup(2).times.sample(10).times
  end
end

describe 'Memory usage' do
  it 'checks memory usage to be less 25 MB' do
    work('data25000.txt', 'result.json')
    memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    
    expect(memory).to be < 25
  end
end
