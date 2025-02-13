# frozen_string_literal: true

require 'rspec-benchmark'
require_relative '../task-2'

RSpec.describe 'Memory usage' do
  include RSpec::Benchmark::Matchers

  before do
    File.write('result.json', '')
  end

  it 'consumes no more than 70 MB of memory' do
    expect { work('data_large.txt', 'result.json') }
      .to perform_allocation(70_000_000).bytes
  end
end
