# frozen_string_literal: true

require 'json'
require 'rspec-benchmark'
require_relative '../task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe 'Task №2' do
  describe '#work' do
    context 'health check' do
      let(:result_data) { File.read('spec/fixtures/result.json') }

      it 'returns users data(in json)' do
        work('spec/fixtures/data18.txt')
        expect(JSON.parse(File.read('result.json'))).to eq(JSON.parse(result_data))
      end
    end

    context 'checking the amount of allocated memory' do
      it 'allocates less than 70MB in memory' do
        expect { work('data_large.txt') }.to perform_allocation(70_000_00).bytes
      end
    end
  end
end

