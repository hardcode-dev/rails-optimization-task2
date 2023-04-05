require_relative 'spec_helper.rb'
require_relative '../task-2.rb'

describe 'Assert Performance' do
  describe '#work' do
    it 'works under 200 ms for size 32_500 lines' do
      expect {
        work(file: 'data/data_32_500.txt')
      }.to perform_under(150).ms.warmup(2).times.sample(10).times
    end
  end
end
