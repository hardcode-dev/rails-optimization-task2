require_relative '../parser.rb'

describe 'Performance' do
  describe 'parsing' do
    let(:budget) { 35_000 }
    let(:data) { 'data/data_large.txt' }

    describe 'task_2(parsing large file)' do
      it 'works under 30sec' do
        expect { Parser.new(disable_gc: true).work(data) }
          .to perform_under(budget).ms.warmup(1).times.sample(2).times
      end
    end
  end
end
