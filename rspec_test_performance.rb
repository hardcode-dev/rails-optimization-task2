# frozen_string_literal: true

require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

def prepare_file(size)
  system("head -n #{size} data_large.txt > data_#{size}.txt")
end

def linear_work(size)
  prepare_file(size)
  work("data_#{size}.txt")
end

describe 'Performance' do
  describe 'linear work' do
    let(:size) { 500_000 }
    it 'works under 5 s' do
      expect do
        linear_work(size)
      end.to perform_under(5).sec.warmup(2).times.sample(5).times
    end

    let(:sizes) { [500_000, 1_000_000, 1_500_000] }
    it 'performs linear' do
      expect { |n, _i| linear_work(n) }.to perform_linear.in_range(sizes)
    end

    let(:size_for_mem) { 50_000 }
    it 'works under 50Mb' do
      expect do
        linear_work(size_for_mem)
      end.to perform_allocation(70_000_000).bytes
    end
  end
end
