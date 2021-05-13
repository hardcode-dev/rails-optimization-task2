require_relative '../parser.rb'

describe 'Memory performance' do
  describe 'parsing' do
    let(:metric_budget) { (55) * 1024 }

    describe '_protection of the metric from further degradation' do
      it '(expectations on the memory size(bytes))' do
        expect { Parser.new.work('spec/test_data/data.txt') }
          .to perform_allocation(metric_budget).bytes
      end
    end
  end
end
