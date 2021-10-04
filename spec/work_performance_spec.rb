require 'rspec'
require 'rspec-benchmark'

require_relative '../work.rb'

describe 'work performance' do
  include RSpec::Benchmark::Matchers

  it 'performs large data under 15 sec' do
    expect {
      work(filename: 'data_large.txt', disable_gc: false)
    }.to perform_under(15).sec
  end

  it 'respects memory allocation limit' do
    work(filename: 'data_large.txt', disable_gc: false)
    allocated_memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(allocated_memory).to be < 70
  end
end
