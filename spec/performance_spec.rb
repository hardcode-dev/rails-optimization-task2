require_relative '../task-2'
require 'rspec'

RSpec.describe 'Performance' do
  subject(:work!) do
    before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts before
    work(file_path)
    after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
    puts after
    after - before
  end

  describe '10000.txt' do
    let(:file_path) { 'samples/10000.txt' }
    it { is_expected.to be <= 80 }
  end

  # Опционально
  # describe 'data_large.txt' do
  #   let(:file_path) { 'data_large.txt' }
  #   it { is_expected.to be <= 70 }
  # end
end
