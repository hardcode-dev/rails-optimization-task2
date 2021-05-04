require 'rspec-benchmark'
require 'rspec'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe '#work' do
  it 'allocates less than 131,000 bytes in memory  ' do
    expect { work('data.txt') }.to perform_allocation(131000).bytes
  end
end
