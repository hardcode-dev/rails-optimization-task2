require_relative 'spec_helper.rb'
require_relative '../task-2.rb'

describe 'Perform allocation' do
  describe '#work' do
    it 'perform allocation' do
      expect {
        work(file: 'data/data_1000.txt')
      }.to perform_allocation(14_000)
    end
  end
end
