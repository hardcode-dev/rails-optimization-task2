require 'spec_helper'

RSpec.describe '#work' do

  it 'works under 2s' do
    expect { work('data/data_10000.txt') }.to perform_under(0.03).sec
  end

  it 'uses less than 30Mb memory' do
    expect { work('data/data_10000.txt') }.to perform_allocation(30_000_000).bytes
  end
end
