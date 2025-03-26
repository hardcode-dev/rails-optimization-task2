require_relative 'task-2'
require 'rspec'
require 'rspec-benchmark'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'memory limits' do
  it 'limits memory usage' do
    expect(work('data_large.txt')).to be <= 70
  end
end