require_relative 'task-2'
require 'rspec'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'data20000.txt' do
  it 'allocates less than 20 mb' do
    expect do
      work('data20000.txt')
    end.to perform_allocation(20_000_000).bytes
  end
end
