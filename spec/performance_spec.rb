# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'execution time' do
    before { GC.disable }
    after { GC.enable }

    it 'performs large file in less than 30 seconds' do
      expect do
        work('spec/fixtures/data_100000.txt')
      end.to perform_under(30).sec
    end
  end

  describe 'memory usage' do
    before { GC.compact }

    it 'performs data_500 file in less than 700 kylobytes' do
      expect do
        work('spec/fixtures/data_500.txt')
      end.to perform_allocation(700_000).bytes
    end
  end
end
