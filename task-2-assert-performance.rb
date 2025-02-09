# rspec task-2-assert-performance.rb

require 'rspec-benchmark'
require_relative 'task-2'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'task-2#work' do
    let(:file_name) { 'data_large.txt' }

    it 'works with large allocating less than 70 Mb' do
      expect(File.size(file_name)).to eq(134424508) # байт
      expect(work(file_name:)).to be < 70
    end
  end
end
