# frozen_string_literal: true

require 'rspec-benchmark'
require 'rspec'
require_relative '../task-2'

describe 'Task-2' do
  include RSpec::Benchmark::Matchers

  describe 'Memory allocation' do
    let(:file_name) { './datasets/data3000.txt' }

    it do
      expect do
        work(file_name)
      end.to perform_allocation(5_000_000).bytes
    end

    it do
      expect do
        work(file_name)
      end.to perform_under(87).ms.warmup(1).times.sample(5).times
    end
  end

  describe 'Performance' do
    let(:file_name) { './datasets/data100_000.txt' }

    it do
      expect do
        work(file_name)
      end.to perform_under(300).ms.warmup(1).times.sample(5).times
    end
  end
end
