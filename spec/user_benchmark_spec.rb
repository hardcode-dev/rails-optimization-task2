require 'spec_helper'

RSpec.describe '#work' do

  it 'works under 2s' do
    expect { work('data/data_10000.txt') }.to perform_under(2).sec
  end

  it 'uses less than 50mb memory' do
    expect { work('data/data_4000.txt') }.to perform_allocation(80_000_000).bytes
  end
end
