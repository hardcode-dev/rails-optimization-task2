
require 'rspec-benchmark'
require_relative '../work'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'uses under 30MB of memory' do
    expect do
      work('test_data.txt')
    end.to perform_allocation(31457280).bytes
  end

  it 'performs under 7 seconds' do
    expect do
      work('data_large_sample.txt')
    end.to perform_under(7).sec
  end
end