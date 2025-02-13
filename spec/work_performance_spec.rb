# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'WorkPerformance' do
  describe '.work' do
    context 'when file contains 50 thousand lines' do
      it 'performs under 1 second' do
        expect { work(file_name: 'data_50_thousands_lines.txt') }.to perform_under(1).sec
      end
    end

    context 'when file contains 500 thousands lines' do
      it 'performs under 5 seconds' do
        expect { work(file_name: 'data_500_thousands_lines.txt') }.to perform_under(5).sec
      end
    end
  end
end
