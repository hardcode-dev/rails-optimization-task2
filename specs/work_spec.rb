# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task_2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Parse#work' do
  it 'test that all works' do
    work('data.txt')
    expected_result = File.read('specs/expected_result.json')
    expect(File.read('result.json')).to eq(expected_result)
  end

  xit 'works under 7 sec for BIG data' do
    expect { work('data_large.txt') }.to perform_under(7).sec
  end
end

describe 'Check memory usage' do
  xit 'allocate less that 40 Mb for BIG data ' do
    before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    work('data_large.txt')
    after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    expect(after - before).to be <= 40
  end
end
