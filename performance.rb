require 'rspec/core'
require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'basic work' do
  let(:filepath) { 'data/data_test.txt' }

  it 'eats less than 30MB' do
    expect { work(filepath) }
      .to perform_allocation(30_000_000).bytes
  end
end
