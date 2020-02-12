require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'allocates less than 40Mb' do
    expect {
      work('data100000.txt', disable_gc: false)
    }.to perform_allocation(50 * 1024 * 1024).bytes
  end
end
