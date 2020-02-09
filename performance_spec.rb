require 'rspec-benchmark'
require_relative 'task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  let(:file_name) { 'data_40000.txt' }

  it 'На обработку выделяется не более 40 MB памяти' do
    expect do
      work(file_name, disable_gc: false)
    end.to perform_allocation(40 * 1024 * 1024).memory
  end
end
