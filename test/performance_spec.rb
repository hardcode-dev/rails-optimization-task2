require 'rspec-benchmark'
require_relative '../task-2.rb'

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end

describe 'Performance' do
  describe 'linear work' do
    let(:file_path) { "#{__dir__}/../data/data2.txt" }

    it '40000 rows works under 210ms' do
      expect do
        work(file2_path)
      end.to perform_under(0.21).sec.warmup(2).times.sample(10).times
    end

    it 'uses no more than 70mb' do
      memory_before = `ps -o rss= -p #{Process.pid}`.to_i / 1024
      work(file_path)
      memory_after = `ps -o rss= -p #{Process.pid}`.to_i / 1024
      # считаем сколько имено наша программа съела памяти
      memory_used = memory_after - memory_before

      expect(memory_used).to be < 70
    end

    # its bad (
    # it 'has linear asymptotics' do
    #   expect do |n, _i|
    #     worker = Worker.new("#{__dir__}/../data/data#{n}.txt")
    #     worker.run
    #   end.to perform_linear.in_range([1, 2, 3, 4]).sample(10).times
    # end
  end
end
