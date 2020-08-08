# frozen_string_literal: true

require_relative '../task-2'

RSpec.describe 'Performance' do
  subject(:work!) do
    work(filename: 'data_small.txt')

    `ps -o rss= -p #{Process.pid}`.to_i / 1024
  end

  before { `head -n 12500 data_large.txt > data_small.txt` }
  after { `rm data_small.txt` }

  it { is_expected.to be <= 115 }
end
