require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  it 'requests less than 50 MB RAM' do
    expect {
      work('data10000.txt', disable_gc: false)
    }.to perform_allocation(50 * 1024 * 1024).bytes
  end
end
