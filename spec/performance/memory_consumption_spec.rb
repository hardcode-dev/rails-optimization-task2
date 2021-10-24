# frozen_string_literal: true

require_relative '../../task-2'

RSpec.describe('Benchmark of work method') do
  describe 'memory_consumption' do
    # it 'fits within memory limit' do
    # 	expect { work(file_name: 'spec/fixtures/data_10000.txt') }.to perform_allocation(10_000_000).bytes
    # end

    it 'has constant memory usage complexity' do
      used_memory_for_10_000_lines = work(file_name: 'spec/fixtures/data_10000.txt', return_memory_usage: true)
      used_memory_for_50_000_lines = work(file_name: 'spec/fixtures/data_10000.txt', return_memory_usage: true)

      expect(used_memory_for_10_000_lines).to be_between(25, 40)
      expect(used_memory_for_50_000_lines).to be_between(25, 40)
    end
  end
end
