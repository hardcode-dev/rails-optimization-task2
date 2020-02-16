require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Work' do
  it 'spends less then 70 MB' do
    expect { Report.new.work(filename: 'data_large_100000.txt') }.to perform_allocation(73_400_320).bytes
  end
end
