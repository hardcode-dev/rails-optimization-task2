require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance.' do
    it '"work" should run under 30 seconds' do
      expect { work('data_large.txt') }.to perform_under(35).ms.warmup(1).times.sample(3).times
    end
end

describe 'Work' do
  it 'spends less then 70 MB' do
    memory_usage_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024

    puts "RSS size before programm execution: #{memory_usage_before} Mb."

    work('data_large.txt')

    memory_usage_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts "RSS size after programm execution: #{memory_usage_before} Mb."

    memory_usage_diff = memory_usage_after - memory_usage_before

    expect(memory_usage_after - memory_usage_before).to be <= 70
  end
end
