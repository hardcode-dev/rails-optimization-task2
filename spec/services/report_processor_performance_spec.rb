# frozen_string_literal: true

require 'rspec'
require 'rspec-benchmark'
require_relative '..//../report_processor'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

RSpec.describe ReportProcessor do
  subject(:service) { described_class.new }

  describe '#performance check' do
    context 'when file contains 3_250_940 lines' do
      it 'performs under 10 seconds' do
        expect { service.call(input_file_name: 'data_large.txt') }.to perform_under(10).sec
      end
    end
  end
end
