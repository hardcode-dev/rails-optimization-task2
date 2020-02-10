# frozen_string_literal: true

require 'rspec-benchmark'
require 'benchmark/memory'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Report' do
  describe '#call' do
    it 'works on 100_000 items under 1 sec' do
      expect { Report.new.call('data100000.txt') }.to perform_under(1).sec
    end

    it 'allocate less when 8 Mb ram' do
      bench_malloc = Benchmark::Malloc.new
      stats = bench_malloc.run { Report.new.call('data_small.txt') }
      expect(stats.allocated.total_memory / (1024.0 * 1024.0)).to be < 8
    end

  end
end
