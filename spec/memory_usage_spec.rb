require_relative '../parser.rb'

describe 'Memory performance' do
  describe 'parsing' do
    let(:metric_budget) { 34 }
    let(:data) { 'data/data_large.txt' }

    describe '_protection of the metric from further degradation' do
      it '(expectations on the memory consumes less then _MB)' do
        # expect { Parser.new.work('data/data_large.txt') }
        #   .to perform_allocation(metric_budget).bytes

        # memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
        Parser.new.work(data)
        memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024

        expect(memory_after).to be <= metric_budget
        # expect(memory_after - memory_before).to be <= metric_budget
      end
    end
  end
end
