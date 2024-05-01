# frozen_string_literal: true

require 'rspec-benchmark'
require 'rspec'
require_relative '../task-2'

describe 'Task-2' do
  include RSpec::Benchmark::Matchers

  describe 'Performance' do
    let(:file_name) { './datasets/data1000.txt' }

    it do
      expect do
        work(file_name)
      end.to perform_allocation(1000).bytes
    end
  end

  # describe 'full data set' do
  #   let(:file_name) { './data10_000.txt' }

  #   it 'works faster' do
  #     expect { WorkV5.work(file_name) }.to perform_faster_than { InitWork.work(file_name) }.at_least(33).times
  #   end
  # end

  # describe 'Complexity' do
  #   let(:file_names) { %w[data1000.txt data2000.txt data4000.txt data8000.txt data16000.txt] }

  #   it 'performs perform_power' do
  #     expect { |_n, i| InitWork.work(file_names[i]) }.to perform_power.in_range(8, 32_768).ratio(8)
  #     expect { |_n, i| WorkV5.work(file_names[i]) }.to perform_linear
  #   end
  # end
end
