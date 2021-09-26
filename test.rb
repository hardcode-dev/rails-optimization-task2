require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Perfomance' do
  describe 'work' do
    it 'allocates less then 50 MB' do
      work('files/data_100_000.txt')
      expect(`ps -o rss= -p #{Process.pid}`.to_i / 1024).to be <= 50
    end
  end
end