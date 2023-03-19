require 'rspec/core'
require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'basic work' do
  let(:filepath) { 'data/data_40k.txt' }

  # start point: 15.48s
  # end point: 0.1s

  # it 'eats less than 400MB' do
  #   bench_malloc = Benchmark::Malloc.new
  #   stats = bench_malloc.run { work(filepath) }
  #
  #   expect(stats.allocated.total_memory).to eq 70_000_000
  # end

  it 'eats less than 70MB' do
    expect { work(filepath) }
      .to perform_allocation(7_000_000_000).bytes
  end
  # 6_698_500_030
  # 7_000_000
end
