require 'rspec'
require 'rspec-benchmark'
require_relative '../task-2'

RSpec.describe 'work' do
  include RSpec::Benchmark::Matchers

  it 'should be linear' do
    expect { |number, _|
      `head -n #{number * 1000} data_large.txt > data.txt`

      work
    }.to perform_linear.in_range(1, 100)
  end

  it 'should perform under 5 seconds' do
    `head -n 1000000 data_large.txt > data.txt`

    expect { work }.to perform_under(5).sec
  end

  it 'should not allocate more than 110000 objects' do
    `head -n 10000 data_large.txt > data.txt`

    expect { work }.to perform_allocation(109643)
  end
end
