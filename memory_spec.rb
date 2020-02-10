require "rspec"
require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe "BenchmarkSpec" do
  let(:record_memory) { ("MEMORY USAGE: %d MB" % (`ps -o rss= -p #{Process.pid}`.to_i / 1024)).to_i }
  it do
    start_memory = record_memory
    work("data_large.txt")
    end_memory = record_memory
    expect(end_memory - start_memory).to be <= 70
  end
end
