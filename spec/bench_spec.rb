# frozen_string_literal: true

require 'tempfile'

RSpec.describe '#work', :benchmark do
  context 'for large data' do
    let(:source) { 'samples/data_large.txt' }

    it 'eats up less than 70 MB' do
      Tempfile.create do |result|
        work(src: source, dest: result.path)

        memory_usage = `ps -o rss= -p #{Process.pid}`.to_i / 1024

        expect(memory_usage).to be < 70
      end
    end
  end
end
