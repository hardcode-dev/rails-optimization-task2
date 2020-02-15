# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
describe 'Memory consumption' do
  it 'comsumpts not more 40 MB' do
    expect { work(file_name: 'files/data_large.txt') }.to perform_allocation(4_943_000).bytes
  end
end
